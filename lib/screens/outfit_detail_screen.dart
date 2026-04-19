import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/media_url.dart';
import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../widgets/app_drawer.dart';

class OutfitDetailScreen extends ConsumerStatefulWidget {
  const OutfitDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends ConsumerState<OutfitDetailScreen> {
  Map<String, dynamic>? _o;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final o = await ref.read(outfitsRepositoryProvider).get(widget.id);
    setState(() {
      _o = o;
      _loading = false;
    });
  }

  Widget _tile(String label, dynamic refPrenda) {
    final base = ref.read(apiBaseUrlProvider);
    if (refPrenda is! Map) return ListTile(title: Text(label), subtitle: const Text('—'));
    final url = resolveMediaUrl(base, refPrenda['imagen_url']?.toString());
    return ListTile(
      leading: url.isEmpty ? const Icon(Icons.checkroom) : Image.network(url, width: 48, height: 48, fit: BoxFit.cover),
      title: Text(label),
      subtitle: Text('${refPrenda['tipo']} · ${refPrenda['clase_nombre']}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit')),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _o == null
              ? const SizedBox.shrink()
              : ListView(
                  children: [
                    ListTile(
                      title: Text('Score ${_o!['puntuacion']}'),
                      subtitle: Text(_o!['explicacion']?.toString() ?? ''),
                    ),
                    _tile('Dress', _o!['vestido_id']),
                    _tile('Top', _o!['superior_id']),
                    _tile('Bottom', _o!['inferior_id']),
                    _tile('Shoes', _o!['zapatos_id']),
                    _tile('Coat', _o!['abrigo_id']),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OutlinedButton(
                        onPressed: () => context.go('/wardrobe/outfits'),
                        child: const Text('Back to outfits'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
