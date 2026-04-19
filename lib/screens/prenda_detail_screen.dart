import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/media_url.dart';
import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../widgets/sw_components.dart';

class PrendaDetailScreen extends ConsumerStatefulWidget {
  const PrendaDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<PrendaDetailScreen> createState() => _PrendaDetailScreenState();
}

class _PrendaDetailScreenState extends ConsumerState<PrendaDetailScreen> {
  Map<String, dynamic>? _p;
  bool _loading = true;
  String? _error;

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
      final p = await ref.read(garmentsRepositoryProvider).get(widget.id);
      setState(() {
        _p = p;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _editOccasion() async {
    final current = (_p?['ocasion'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
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
      final updated = await ref.read(garmentsRepositoryProvider).updateOccasion(widget.id, next);
      setState(() => _p = updated);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _delete() async {
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
      await ref.read(garmentsRepositoryProvider).delete(widget.id);
      if (mounted) context.go('/wardrobe');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(apiBaseUrlProvider);
    return Scaffold(
      backgroundColor: SwColors.white,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/wardrobe')),
        title: const Text('Garment'),
      ),
      body: SwPageContainer(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: SwCard(child: Text(_error!)))
                : _p == null
                    ? const SizedBox.shrink()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          SwCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AspectRatio(
                                  aspectRatio: 4 / 5,
                                  child: Builder(
                                    builder: (context) {
                                      final u = resolveMediaUrl(base, _p!['imagen_url']?.toString());
                                      if (u.isEmpty) {
                                        return Container(color: SwColors.light);
                                      }
                                      return Image.network(u, fit: BoxFit.cover);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_p!['tipo']}',
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Class: ${_p!['clase_nombre']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      if ((_p!['color']?.toString() ?? '').isNotEmpty)
                                        Text('Color: ${_p!['color']}', style: const TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Occasions: ${(_p!['ocasion'] as List?)?.join(', ') ?? ''}',
                                        style: const TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _editOccasion,
                                              child: const Text('EDIT OCCASION'),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: FilledButton(
                                              onPressed: _delete,
                                              child: const Text('DELETE'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
