import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../utils/mirror_context.dart';
import '../widgets/sw_components.dart';

class MirrorContextScreen extends ConsumerStatefulWidget {
  const MirrorContextScreen({super.key});

  @override
  ConsumerState<MirrorContextScreen> createState() => _MirrorContextScreenState();
}

class _MirrorContextScreenState extends ConsumerState<MirrorContextScreen> {
  final _occasion = TextEditingController();
  final _weather = TextEditingController();
  final _time = TextEditingController();
  final _style = TextEditingController();
  final _notes = TextEditingController();
  final _location = TextEditingController();
  final _advanced = TextEditingController();
  bool _advancedOpen = false;

  static const _occasions = ['work', 'date', 'travel', 'gym', 'formal', 'casual', 'weekend'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await loadMirrorContext();
    setState(() {
      _occasion.text = c.occasion;
      _weather.text = c.weather;
      _time.text = c.time;
      _style.text = c.style;
      _notes.text = c.notes;
      _location.text = c.location;
    });
  }

  Future<void> _saveLocal() async {
    await saveMirrorContext(MirrorContext(
      occasion: _occasion.text,
      weather: _weather.text,
      time: _time.text,
      style: _style.text,
      notes: _notes.text,
      location: _location.text,
    ));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Context saved')));
  }

  Future<void> _runAdvanced() async {
    final prompt = _advanced.text.trim();
    if (prompt.isEmpty) return;
    try {
      final res = await ref.read(mirrorRepositoryProvider).analyze(prompt);
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mirror result'),
          content: SingleChildScrollView(child: Text(res.toString())),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  void dispose() {
    _occasion.dispose();
    _weather.dispose();
    _time.dispose();
    _style.dispose();
    _notes.dispose();
    _location.dispose();
    _advanced.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Mirror context'),
      ),
      body: SwPageContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text(
              'Set occasion, weather, and notes used by Mirror and Generate.',
              style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 14),
            SwCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SwLabel('Occasion'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final o in _occasions)
                        SwFilterChip(
                          label: o,
                          selected: _occasion.text.trim().toLowerCase() == o,
                          onTap: () => setState(() => _occasion.text = o),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _occasion,
                    decoration: const InputDecoration(labelText: 'Occasion (free text)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _location,
                          decoration: const InputDecoration(labelText: 'Location'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _weather.text = 'Clear · 72°F';
                            _time.text = DateTime.now().toLocal().toString().substring(0, 16);
                          });
                        },
                        child: const Text('WEATHER'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: _weather, decoration: const InputDecoration(labelText: 'Weather')),
                  TextField(controller: _time, decoration: const InputDecoration(labelText: 'Time')),
                  TextField(controller: _style, decoration: const InputDecoration(labelText: 'Style')),
                  TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: _advancedOpen,
                onExpansionChanged: (v) => setState(() => _advancedOpen = v),
                tilePadding: EdgeInsets.zero,
                title: const Text('ADVANCED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                children: [
                  TextField(
                    controller: _advanced,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Custom prompt to mirror analyze'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(onPressed: _runAdvanced, child: const Text('EVALUATE TEXT')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(onPressed: () => context.pop(), child: const Text('CANCEL')),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await _saveLocal();
                      if (mounted) context.pop();
                    },
                    child: const Text('SAVE AND RETURN'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
