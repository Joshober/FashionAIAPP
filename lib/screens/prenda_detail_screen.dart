import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/media_url.dart';
import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../widgets/app_drawer.dart';

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
        title: const Text('Occasions'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'comma-separated, e.g. work, weekend'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
      appBar: AppBar(
        title: const Text('Garment'),
        actions: [
          if (_p != null)
            IconButton(onPressed: _editOccasion, icon: const Icon(Icons.edit_calendar_outlined)),
          if (_p != null) IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _p == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Builder(
                              builder: (context) {
                                final u = resolveMediaUrl(base, _p!['imagen_url']?.toString());
                                if (u.isEmpty) {
                                  return Container(color: Colors.grey.shade300);
                                }
                                return Image.network(u, fit: BoxFit.cover);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Type: ${_p!['tipo']}', style: Theme.of(context).textTheme.titleMedium),
                        Text('Class: ${_p!['clase_nombre']}'),
                        Text('Color: ${_p!['color']}'),
                        Text('Confidence: ${_p!['confianza']}'),
                        Text('Occasions: ${(_p!['ocasion'] as List?)?.join(', ') ?? ''}'),
                      ],
                    ),
    );
  }
}
