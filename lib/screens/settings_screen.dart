import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import '../providers/auth_token.dart';
import '../providers/repositories.dart';
import '../services/auth0_service.dart';
import '../utils/mirror_context.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _style = TextEditingController();
  final _formality = TextEditingController();
  final _palette = TextEditingController();
  final _climate = TextEditingController();
  final _notes = TextEditingController();
  final _avoid = TextEditingController();
  bool _voice = false;

  @override
  void initState() {
    super.initState();
    _pull();
  }

  Future<void> _pull() async {
    try {
      final p = await ref.read(preferencesRepositoryProvider).getPreferences();
      final v = await loadVoiceReplyEnabled();
      setState(() {
        _style.text = p['style_preference']?.toString() ?? '';
        _formality.text = p['formality']?.toString() ?? '';
        _palette.text = p['palette']?.toString() ?? '';
        _climate.text = p['climate']?.toString() ?? '';
        _notes.text = p['notes']?.toString() ?? '';
        _avoid.text = p['avoid']?.toString() ?? '';
        _voice = v;
      });
    } catch (_) {
      /* ignore */
    }
  }

  Map<String, dynamic> _prefs() => {
        'style_preference': _style.text,
        'formality': _formality.text,
        'palette': _palette.text,
        'climate': _climate.text,
        'notes': _notes.text,
        'avoid': _avoid.text,
      };

  Future<void> _save() async {
    try {
      await ref.read(preferencesRepositoryProvider).putPreferences(_prefs());
      final ctx = await loadMirrorContext();
      await saveMirrorContext(MirrorContext(
        occasion: ctx.occasion,
        weather: ctx.weather,
        time: ctx.time,
        style: _style.text,
        notes: ctx.notes,
        location: ctx.location,
      ));
      await saveVoiceReplyEnabled(_voice);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
    final auth0 = ref.watch(auth0ServiceProvider);
    final token = ref.watch(authTokenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth0Configured()) ...[
            ListTile(
              title: Text((token == null || token.isEmpty) ? 'Signed out' : 'Signed in'),
              trailing: (token == null || token.isEmpty)
                  ? FilledButton(
                      onPressed: () async {
                        await auth0?.login();
                        if (context.mounted) setState(() {});
                      },
                      child: const Text('Login'),
                    )
                  : OutlinedButton(
                      onPressed: () async {
                        await auth0?.logout();
                        if (context.mounted) setState(() {});
                      },
                      child: const Text('Logout'),
                    ),
            ),
            const Divider(),
          ],
          SwitchListTile(
            title: const Text('Voice replies in chat (TTS)'),
            value: _voice,
            onChanged: (v) => setState(() => _voice = v),
          ),
          TextField(controller: _style, decoration: const InputDecoration(labelText: 'Style preference')),
          TextField(controller: _formality, decoration: const InputDecoration(labelText: 'Formality')),
          TextField(controller: _palette, decoration: const InputDecoration(labelText: 'Palette')),
          TextField(controller: _climate, decoration: const InputDecoration(labelText: 'Climate')),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
          TextField(controller: _avoid, decoration: const InputDecoration(labelText: 'Avoid')),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
