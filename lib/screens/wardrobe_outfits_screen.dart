import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../utils/outfit_visuals.dart';
import '../widgets/saved_outfit_grid_card.dart';
import '../widgets/sw_components.dart';
import '../widgets/wardrobe_sub_nav.dart';

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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(outfitsRepositoryProvider).delete(id);
    await _load();
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
                      Row(
                        children: [
                          const Expanded(child: SwHeading('Saved outfits')),
                          TextButton(
                            onPressed: () => context.go('/generate'),
                            child: const Text('GENERATE', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const WardrobeSubNav(garmentsSelected: false),
                    ],
                  ),
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              SliverToBoxAdapter(
                child: SwPageContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SwEmptyState(
                      title: 'No saved outfits',
                      subtitle: 'Generate suggestions and save your favorites.',
                      actionLabel: 'Go to generate',
                      onAction: () => context.go('/generate'),
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
                          itemCount: _items.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cross,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.92,
                          ),
                          itemBuilder: (context, i) {
                            final o = _items[i];
                            final id = o['_id']?.toString() ?? '';
                            final urls = outfitImageUrls(base, o);
                            return SavedOutfitGridCard(
                              imageUrls: urls,
                              scoreLabel: 'Score ${o['puntuacion'] ?? '—'}',
                              onTap: () => context.go('/wardrobe/outfit/$id'),
                              onDelete: () => _delete(id),
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
