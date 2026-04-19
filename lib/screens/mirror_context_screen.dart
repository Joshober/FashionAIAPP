import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repositories.dart';
import '../utils/mirror_context.dart';
import '../widgets/app_drawer.dart';

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
      appBar: AppBar(title: const Text('Mirror context')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _occasion, decoration: const InputDecoration(labelText: 'Occasion')),
          TextField(controller: _weather, decoration: const InputDecoration(labelText: 'Weather')),
          TextField(controller: _time, decoration: const InputDecoration(labelText: 'Time')),
          TextField(controller: _style, decoration: const InputDecoration(labelText: 'Style')),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
          FilledButton(onPressed: _saveLocal, child: const Text('Save context')),
          const Divider(height: 32),
          Text('Advanced (text-only)', style: Theme.of(context).textTheme.titleSmall),
          TextField(
            controller: _advanced,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Direct prompt to mirror analyze'),
          ),
          OutlinedButton(onPressed: _runAdvanced, child: const Text('Run advanced analyze')),
        ],
      ),
    );
  }
}
