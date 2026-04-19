import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/env.dart';
import '../providers/auth_token.dart';
import '../providers/repositories.dart';
import '../services/auth0_service.dart';
import '../theme/app_theme.dart';
import '../utils/mirror_context.dart';
import '../widgets/preferences_editor_sheet.dart';
import '../widgets/sw_components.dart';

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
  bool _loading = true;
  bool _editing = false;
  String? _banner;

  @override
  void initState() {
    super.initState();
    _pull();
  }

  Future<void> _pull() async {
    setState(() {
      _loading = true;
      _banner = null;
    });
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
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
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
      if (mounted) {
        setState(() {
          _editing = false;
          _banner = 'Saved';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _banner = e.toString());
    }
  }

  Future<void> _openPrefsSheet() {
    return showPreferencesEditor(
      context,
      style: _style,
      formality: _formality,
      palette: _palette,
      climate: _climate,
      notes: _notes,
      avoid: _avoid,
      onSave: () async {
        await _save();
      },
    );
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
    final authed = token != null && token.isNotEmpty;

    if (!authed && auth0Configured()) {
      return Scaffold(
        backgroundColor: SwColors.white,
        body: Center(
          child: SwPageContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SwCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SwHeading('Account'),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to sync preferences and wardrobe.',
                      style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await auth0?.login();
                        if (mounted) {
                          context.go('/settings');
                          setState(() {});
                        }
                      },
                      child: const Text('SIGN IN'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_loading) {
      return const Scaffold(
        backgroundColor: SwColors.white,
        body: Center(child: Text('LOADING…', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1))),
      );
    }

    return Scaffold(
      backgroundColor: SwColors.white,
      body: SwPageContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(child: SwHeading('Settings')),
                if (!_editing)
                  TextButton(
                    onPressed: () => setState(() => _editing = true),
                    child: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.w900)),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _editing = false;
                        _pull();
                      });
                    },
                    child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SwLabel('Account'),
                  const SizedBox(height: 8),
                  Text(authed ? 'Signed in' : 'Local session', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(onPressed: () => context.go('/wardrobe'), child: const Text('WARDROBE')),
                      OutlinedButton(onPressed: () => context.push('/chat'), child: const Text('CHAT')),
                      OutlinedButton(onPressed: () => context.go('/generate'), child: const Text('GENERATE')),
                      OutlinedButton(onPressed: () => context.go('/mirror'), child: const Text('MIRROR')),
                    ],
                  ),
                ],
              ),
            ),
            if (_banner != null) ...[
              const SizedBox(height: 12),
              SwCard(
                child: Text(_banner!, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
            const SizedBox(height: 14),
            if (_editing)
              SwCard(
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: SwColors.accent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You are editing preferences.',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            if (_editing) const SizedBox(height: 12),
            SwCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SwLabel('Outfit preferences'),
                  const SizedBox(height: 8),
                  if (!_editing)
                    Text(
                      [
                        if (_style.text.isNotEmpty) 'Style: ${_style.text}',
                        if (_palette.text.isNotEmpty) 'Palette: ${_palette.text}',
                        if (_formality.text.isNotEmpty) 'Formality: ${_formality.text}',
                      ].join('\n'),
                      style: const TextStyle(height: 1.35, fontWeight: FontWeight.w600),
                    )
                  else ...[
                    TextField(controller: _style, decoration: const InputDecoration(labelText: 'Style preference')),
                    TextField(controller: _formality, decoration: const InputDecoration(labelText: 'Formality')),
                    TextField(controller: _palette, decoration: const InputDecoration(labelText: 'Palette')),
                    TextField(controller: _climate, decoration: const InputDecoration(labelText: 'Climate')),
                    TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes')),
                    TextField(controller: _avoid, decoration: const InputDecoration(labelText: 'Avoid')),
                  ],
                  if (!_editing)
                    TextButton(
                      onPressed: _openPrefsSheet,
                      child: const Text('OPEN FULL EDITOR', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SwLabel('Chat voice'),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Voice replies (TTS)', style: TextStyle(fontWeight: FontWeight.w700)),
                    value: _voice,
                    onChanged: _editing ? (v) => setState(() => _voice = v) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_editing) ...[
              FilledButton(onPressed: _save, child: const Text('SAVE ALL CHANGES')),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  setState(() => _editing = false);
                  _pull();
                },
                child: const Text('DISCARD CHANGES'),
              ),
            ] else ...[
              OutlinedButton(onPressed: () => setState(() => _editing = true), child: const Text('EDIT PREFERENCES')),
            ],
            const SizedBox(height: 12),
            if (auth0Configured())
              TextButton(
                onPressed: () async {
                  await auth0?.logout();
                  if (mounted) setState(() {});
                },
                child: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
          ],
        ),
      ),
    );
  }
}
