import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/media_url.dart';
import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../widgets/prenda_tile_card.dart';
import '../widgets/sw_components.dart';
import '../widgets/wardrobe_sub_nav.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  String _filter = 'all';
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  static const _tipos = ['all', 'superior', 'inferior', 'zapatos', 'abrigo', 'vestido'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(garmentsRepositoryProvider).list();
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _items;
    return _items.where((p) => (p['tipo']?.toString() ?? '') == _filter).toList();
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    try {
      await ref.read(garmentsRepositoryProvider).upload(bytes, x.name);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded')));
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _editOccasion(Map<String, dynamic> p) async {
    final id = p['_id']?.toString() ?? '';
    if (id.isEmpty) return;
    final current = (p['ocasion'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    final ctrl = TextEditingController(text: current.join(', '));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('OCCASIONS'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'comma-separated, e.g. work, weekend'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SAVE')),
        ],
      ),
    );
    if (ok != true) return;
    final next = ctrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    try {
      await ref.read(garmentsRepositoryProvider).updateOccasion(id, next);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _delete(Map<String, dynamic> p) async {
    final id = p['_id']?.toString() ?? '';
    if (id.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete garment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(garmentsRepositoryProvider).delete(id);
      await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  int _cols(double w) {
    if (w >= 1100) return 4;
    if (w >= 720) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(apiBaseUrlProvider);
    return Scaffold(
      backgroundColor: SwColors.white,
      body: RefreshIndicator(
        color: SwColors.accent,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SwPageContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SwLabel('Wardrobe'),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(child: SwDisplay(['MY', 'WARDROBE'])),
                          FilledButton(
                            onPressed: _pickAndUpload,
                            child: const Text('UPLOAD'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '${_items.length} pieces',
                            style: const TextStyle(color: SwColors.gray, fontWeight: FontWeight.w700),
                          ),
                          const Text(' · ', style: TextStyle(color: SwColors.gray)),
                          TextButton(
                            onPressed: () => context.go('/wardrobe/outfits'),
                            child: const Text('SAVED OUTFITS', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const WardrobeSubNav(garmentsSelected: true),
                      SwChipScroller(
                        children: [
                          for (final t in _tipos)
                            SwFilterChip(
                              label: garmentFilterLabel(t),
                              selected: _filter == t,
                              onTap: () => setState(() => _filter = t),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const SwHeading('Garments'),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            if (_error != null)
              SliverToBoxAdapter(
                child: SwPageContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SwCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_error!, style: const TextStyle(color: SwColors.accent, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          OutlinedButton(onPressed: _load, child: const Text('RETRY')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(
                child: SwPageContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SwEmptyState(
                      title: _items.isEmpty ? 'Wardrobe empty' : 'No matches',
                      subtitle: _items.isEmpty ? 'Upload your first garment.' : 'Clear filters to see all garments.',
                      actionLabel: _filter == 'all' ? 'Upload' : 'Show all',
                      onAction: _filter == 'all' ? _pickAndUpload : () => setState(() => _filter = 'all'),
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SwPageContainer(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final cross = _cols(c.maxWidth);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filtered.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cross,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 4 / 5.4,
                          ),
                          itemBuilder: (context, i) {
                            final p = _filtered[i];
                            final url = resolveMediaUrl(base, p['imagen_url']?.toString());
                            final tipo = p['tipo']?.toString() ?? '';
                            final cls = p['clase_nombre']?.toString() ?? '';
                            final occ = (p['ocasion'] as List?)?.take(2).join(', ') ?? '';
                            final id = p['_id']?.toString() ?? '';
                            return PrendaTileCard(
                              imageUrl: url,
                              category: tipo.isEmpty ? 'Garment' : garmentFilterLabel(tipo),
                              subtitle: '$cls · $occ',
                              onTap: () => context.go('/wardrobe/prenda/$id'),
                              onEditOccasion: () => _editOccasion(p),
                              onDelete: () => _delete(p),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
