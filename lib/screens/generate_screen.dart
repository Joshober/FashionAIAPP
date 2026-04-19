import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repositories.dart';
import '../utils/outfit_recommend_query.dart';
import '../utils/mirror_context.dart';
import '../widgets/app_drawer.dart';

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
    try {
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
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      await _savePrefs();
      final q = outfitRecommendQuery(_prefsMap());
      final recs = await ref.read(outfitsRepositoryProvider).recommend(q);
      await saveGeneratedOutfitsCache(recs);
      setState(() => _recs = recs);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate outfits'),
        actions: [
          TextButton(onPressed: _busy ? null : _savePrefs, child: const Text('Save prefs')),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _style, decoration: const InputDecoration(labelText: 'Style preference')),
          TextField(controller: _formality, decoration: const InputDecoration(labelText: 'Formality')),
          TextField(controller: _palette, decoration: const InputDecoration(labelText: 'Palette')),
          TextField(controller: _climate, decoration: const InputDecoration(labelText: 'Climate')),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
          TextField(controller: _avoid, decoration: const InputDecoration(labelText: 'Avoid')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome),
            label: const Text('Generate fresh'),
          ),
          const SizedBox(height: 24),
          Text('Recommendations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_recs.isEmpty)
            const Text('No recommendations yet. Generate to see cards.')
          else
            ..._recs.map((o) {
              return Card(
                child: ListTile(
                  title: Text('Score ${o['puntuacion'] ?? '-'}'),
                  subtitle: Text(o['explicacion']?.toString() ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/generate/outfit', extra: Map<String, dynamic>.from(o)),
                ),
              );
            }),
        ],
      ),
    );
  }
}
