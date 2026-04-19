import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/media_url.dart';
import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool? _apiOk;
  List<Map<String, dynamic>> _prendas = [];
  List<Map<String, dynamic>> _outfits = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
    });
    final health = ref.read(healthRepositoryProvider);
    final garments = ref.read(garmentsRepositoryProvider);
    final outfits = ref.read(outfitsRepositoryProvider);
    final ok = await health.ping();
    if (!ok) {
      setState(() {
        _apiOk = false;
        _prendas = [];
        _outfits = [];
      });
      return;
    }
    try {
      final p = await garments.list();
      final o = await outfits.list();
      setState(() {
        _apiOk = true;
        _prendas = p.take(6).toList();
        _outfits = o.take(6).toList();
      });
    } catch (e) {
      setState(() {
        _apiOk = true;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(apiBaseUrlProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_apiOk == false)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.cloud_off),
                  title: Text('API unreachable'),
                  subtitle: Text('Check backend and API_BASE_URL in assets/env/dev.env'),
                ),
              ),
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/wardrobe'),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Wardrobe'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/generate'),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/chat'),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/mirror'),
                  icon: const Icon(Icons.camera_front),
                  label: const Text('Mirror'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recent garments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_prendas.isEmpty && _apiOk == true)
              const Text('No garments yet.')
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _prendas.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final p = _prendas[i];
                    final id = p['_id']?.toString() ?? '';
                    final url = resolveMediaUrl(base, p['imagen_url']?.toString());
                    return GestureDetector(
                      onTap: () => context.go('/wardrobe/prenda/$id'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: url.isEmpty
                              ? Container(color: Colors.grey.shade300)
                              : Image.network(url, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            Text('Recent outfits', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_outfits.isEmpty && _apiOk == true)
              const Text('No saved outfits yet.')
            else
              ..._outfits.map((o) {
                final id = o['_id']?.toString() ?? '';
                return ListTile(
                  leading: const Icon(Icons.layers),
                  title: Text('Outfit · score ${o['puntuacion'] ?? '-'}'),
                  onTap: () => context.go('/wardrobe/outfit/$id'),
                );
              }),
          ],
        ),
      ),
    );
  }
}
