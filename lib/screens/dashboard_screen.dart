import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/media_url.dart';
import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../utils/classification_display.dart';
import '../utils/outfit_visuals.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/prenda_tile_card.dart';
import '../widgets/saved_outfit_grid_card.dart';
import '../widgets/sw_components.dart';

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _loading = true;
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
        _loading = false;
      });
      return;
    }
    try {
      final p = await garments.list();
      final o = await outfits.list();
      setState(() {
        _apiOk = true;
        _prendas = p.take(8).toList();
        _outfits = o.take(8).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _apiOk = true;
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int _gridColumns(double w) {
    if (w >= 1100) return 4;
    if (w >= 720) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(apiBaseUrlProvider);
    final mq = MediaQuery.sizeOf(context);
    final cols = _gridColumns(mq.width);

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
                child: _HeroBlock(
                  onUpload: () => context.go('/wardrobe'),
                  onGenerate: () => context.go('/generate'),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: MarqueeStrip()),
            SliverToBoxAdapter(
              child: SwPageContainer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_apiOk == false)
                        SwCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: const [
                              Icon(Icons.cloud_off_outlined, color: SwColors.accent),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'API unreachable. Check backend and API_BASE_URL in assets/env/dev.env',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(_error!, style: const TextStyle(color: SwColors.accent, fontWeight: FontWeight.w600)),
                        ),
                      SwSectionRow(
                        title: 'Recent garments',
                        actionLabel: 'View all',
                        onAction: () => context.go('/wardrobe'),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_prendas.isEmpty && _apiOk == true)
                        SwEmptyState(
                          title: 'Upload first',
                          subtitle: 'Add garments to populate your wardrobe.',
                          actionLabel: 'Open wardrobe',
                          onAction: () => context.go('/wardrobe'),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, c) {
                            final cross = _gridColumns(c.maxWidth);
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _prendas.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 4 / 5.2,
                              ),
                              itemBuilder: (context, i) {
                                final p = _prendas[i];
                                final id = p['_id']?.toString() ?? '';
                                final url = resolveMediaUrl(base, p['imagen_url']?.toString());
                                final tipo = p['tipo']?.toString() ?? '';
                                final clsRaw = p['clase_nombre']?.toString() ?? '';
                                final cls = clsRaw.toLowerCase() == 'desconocido'
                                    ? (typeToEnglish(tipo).isEmpty ? 'Unknown' : typeToEnglish(tipo))
                                    : garmentClassLabel(clsRaw);
                                final occ = formatOccasionsEnglish(p['ocasion']);
                                return PrendaTileCard(
                                  imageUrl: url,
                                  category: typeToEnglish(tipo).isEmpty ? 'Unknown' : typeToEnglish(tipo),
                                  subtitle: '$cls · $occ',
                                  onTap: () => context.go('/wardrobe/prenda/$id'),
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 28),
                      SwSectionRow(
                        title: 'Saved outfits',
                        actionLabel: 'View all',
                        onAction: () => context.go('/wardrobe/outfits'),
                      ),
                      if (_loading)
                        const SizedBox.shrink()
                      else if (_outfits.isEmpty && _apiOk == true)
                        SwEmptyState(
                          title: 'Generate outfits',
                          subtitle: 'Create looks from your wardrobe.',
                          actionLabel: 'Generate',
                          onAction: () => context.go('/generate'),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _outfits.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.92,
                          ),
                          itemBuilder: (context, i) {
                            final o = _outfits[i];
                            final id = o['_id']?.toString() ?? '';
                            final urls = outfitImageUrls(base, o);
                            return SavedOutfitGridCard(
                              imageUrls: urls,
                              scoreLabel: 'Score ${o['puntuacion'] ?? '—'}',
                              onTap: () => context.go('/wardrobe/outfit/$id'),
                            );
                          },
                        ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: SwColors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                child: SwPageContainer(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final wide = c.maxWidth >= 720;
                      final row = Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SwLabel('Live mirror', color: SwColors.accent),
                                SizedBox(height: 8),
                                Text(
                                  'TRY YOUR OUTFIT LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    letterSpacing: 0.6,
                                    height: 1.05,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Real-time feedback with camera + AI.',
                                  style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          if (wide) const SizedBox(width: 16),
                          if (wide)
                            FilledButton(
                              onPressed: () => context.go('/mirror'),
                              child: const Text('OPEN MIRROR'),
                            ),
                        ],
                      );
                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            row,
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: () => context.go('/mirror'),
                              child: const Text('OPEN MIRROR'),
                            ),
                          ],
                        );
                      }
                      return row;
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.onUpload, required this.onGenerate});

  final VoidCallback onUpload;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final h = wide ? 320.0 : 260.0;
        return SizedBox(
          height: h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SwColors.light,
                      SwColors.white,
                      SwColors.accent.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      SwColors.black.withOpacity(0.55),
                      SwColors.black.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _HeroCopy(onUpload: onUpload, onGenerate: onGenerate, light: true)),
                          const SizedBox(width: 24),
                          const Expanded(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                'Curated looks.\nConfident dressing.',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _HeroCopy(onUpload: onUpload, onGenerate: onGenerate, light: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onUpload, required this.onGenerate, required this.light});

  final VoidCallback onUpload;
  final VoidCallback onGenerate;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final fg = light ? Colors.white : SwColors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SwLabel('Fashion AI', color: SwColors.accent),
        const SizedBox(height: 10),
        Text(
          'DRESS\nWITH\nINTENT',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w900,
            height: 0.9,
            letterSpacing: -1,
            fontSize: 38,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton(
              onPressed: onUpload,
              child: const Text('UPLOAD GARMENT'),
            ),
            OutlinedButton(
              onPressed: onGenerate,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
              ),
              child: const Text('GENERATE OUTFITS'),
            ),
          ],
        ),
      ],
    );
  }
}
