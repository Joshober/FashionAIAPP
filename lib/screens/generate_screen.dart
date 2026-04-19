import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../utils/outfit_recommend_query.dart';
import '../utils/mirror_context.dart';
import '../utils/outfit_visuals.dart';
import '../widgets/preferences_editor_sheet.dart';
import '../widgets/saved_outfit_grid_card.dart';
import '../widgets/sw_components.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  final _style = TextEditingController();
  final _formality = TextEditingController();
  final _palette = TextEditingController();
  final _climate = TextEditingController();
  final _notes = TextEditingController();
  final _avoid = TextEditingController();

  List<Map<String, dynamic>> _recs = [];
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pullPrefs();
    _pullCache();
  }

  Future<void> _pullPrefs() async {
    try {
      final p = await ref.read(preferencesRepositoryProvider).getPreferences();
      setState(() {
        _style.text = p['style_preference']?.toString() ?? '';
        _formality.text = p['formality']?.toString() ?? '';
        _palette.text = p['palette']?.toString() ?? '';
        _climate.text = p['climate']?.toString() ?? '';
        _notes.text = p['notes']?.toString() ?? '';
        _avoid.text = p['avoid']?.toString() ?? '';
      });
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> _pullCache() async {
    final c = await loadGeneratedOutfitsCache();
    if (c.isNotEmpty) setState(() => _recs = c);
  }

  Map<String, dynamic> _prefsMap() {
    return {
      'style_preference': _style.text,
      'formality': _formality.text,
      'palette': _palette.text,
      'climate': _climate.text,
      'notes': _notes.text,
      'avoid': _avoid.text,
    };
  }

  Future<void> _savePrefs() async {
    await ref.read(preferencesRepositoryProvider).putPreferences(_prefsMap());
    final ctx = await loadMirrorContext();
    await saveMirrorContext(MirrorContext(
      occasion: ctx.occasion,
      weather: ctx.weather,
      time: ctx.time,
      style: _style.text,
      notes: ctx.notes,
      location: ctx.location,
    ));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved')));
  }

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _savePrefs();
      final q = outfitRecommendQuery(_prefsMap());
      final recs = await ref.read(outfitsRepositoryProvider).recommend(q);
      await saveGeneratedOutfitsCache(recs);
      setState(() => _recs = recs);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPrefs() {
    return showPreferencesEditor(
      context,
      style: _style,
      formality: _formality,
      palette: _palette,
      climate: _climate,
      notes: _notes,
      avoid: _avoid,
      onSave: _savePrefs,
    );
  }

  int _cols(double w) {
    if (w >= 1100) return 3;
    if (w >= 720) return 2;
    return 1;
  }

  @override
  void dispose() {
    _style.dispose();
    _formality.dispose();
    _palette.dispose();
    _climate.dispose();
    _notes.dispose();
    _avoid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(apiBaseUrlProvider);
    return Scaffold(
      backgroundColor: SwColors.white,
      body: SwPageContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwHeading('Generate'),
                      SizedBox(height: 8),
                      Text(
                        'Build outfits from your wardrobe. Tune preferences anytime.',
                        style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600, height: 1.35),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Preferences',
                  onPressed: _openPrefs,
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.go('/wardrobe/outfits'),
              child: const Text('VIEW SAVED OUTFITS', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _generate,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('GENERATE FRESH'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => context.push('/chat'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(52, 52)),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Divider(height: 1, color: SwColors.border),
            const SizedBox(height: 18),
            const SwHeading('Recommendations'),
            const SizedBox(height: 12),
            if (_error != null)
              SwCard(
                child: Text(_error!, style: const TextStyle(color: SwColors.accent, fontWeight: FontWeight.w700)),
              ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_recs.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwEmptyState(
                    title: 'No recommendations yet',
                    subtitle: 'Set preferences and generate to see ranked looks.',
                    actionLabel: 'Preferences',
                    onAction: _openPrefs,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _busy ? null : _generate, child: const Text('GENERATE')),
                ],
              )
            else
              LayoutBuilder(
                builder: (context, c) {
                  final cross = _cols(c.maxWidth);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, i) {
                      final o = _recs[i];
                      final urls = outfitImageUrls(base, o);
                      return SavedOutfitGridCard(
                        imageUrls: urls,
                        scoreLabel: 'Score ${o['puntuacion'] ?? '—'}',
                        footerActionLabel: 'Open',
                        onFooterAction: () => context.push('/generate/outfit', extra: Map<String, dynamic>.from(o)),
                        onTap: () => context.push('/generate/outfit', extra: Map<String, dynamic>.from(o)),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
