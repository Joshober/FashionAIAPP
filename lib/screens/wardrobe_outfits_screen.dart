import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repositories.dart';
import '../widgets/app_drawer.dart';

class WardrobeOutfitsScreen extends ConsumerStatefulWidget {
  const WardrobeOutfitsScreen({super.key});

  @override
  ConsumerState<WardrobeOutfitsScreen> createState() => _WardrobeOutfitsScreenState();
}

class _WardrobeOutfitsScreenState extends ConsumerState<WardrobeOutfitsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(outfitsRepositoryProvider).list();
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete outfit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(outfitsRepositoryProvider).delete(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved outfits'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final o = _items[i];
                final id = o['_id']?.toString() ?? '';
                return ListTile(
                  leading: const Icon(Icons.layers_outlined),
                  title: Text('Score: ${o['puntuacion'] ?? '-'}'),
                  subtitle: Text(id),
                  onTap: () => context.go('/wardrobe/outfit/$id'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(id),
                  ),
                );
              },
            ),
    );
  }
}
