import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../core/env.dart';
import '../providers/auth_token.dart';
import '../providers/repositories.dart';
import '../services/auth0_service.dart';
import '../utils/mirror_context.dart';
import '../utils/outfit_recommend_query.dart';
import '../utils/save_outfit_payload.dart';
import '../widgets/app_drawer.dart';

class _Msg {
  _Msg({required this.assistant, required this.text, this.outfits});

  final bool assistant;
  final String text;
  final List<Map<String, dynamic>>? outfits;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[];
  bool _sending = false;
  bool _recording = false;
  bool _voiceReply = false;
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadVoiceReplyEnabled().then((v) => setState(() => _voiceReply = v));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(assistant: false, text: trimmed));
      _sending = true;
    });
    _ctrl.clear();
    _scrollBottom();

    try {
      final repo = ref.read(chatRepositoryProvider);
      final r = await repo.chat(trimmed);
      List<Map<String, dynamic>>? cards;
      if (r.outfitGeneration != null) {
        final q = outfitRecommendQuery(Map<String, dynamic>.from(r.outfitGeneration!));
        cards = await ref.read(outfitsRepositoryProvider).recommend(q);
      }
      setState(() {
        _msgs.add(_Msg(assistant: true, text: r.reply, outfits: cards));
        _sending = false;
      });
      _scrollBottom();

      if (_voiceReply && r.reply.isNotEmpty) {
        try {
          final bytes = await repo.tts(r.reply);
          if (bytes.isNotEmpty) {
            final dir = await getTemporaryDirectory();
            final f = File('${dir.path}/tts_out.wav');
            await f.writeAsBytes(bytes);
            await _player.setFilePath(f.path);
            await _player.play();
          }
        } catch (_) {
          /* TTS optional */
        }
      }
    } on DioException catch (e) {
      setState(() {
        _sending = false;
        _msgs.add(_Msg(assistant: true, text: 'Error: ${e.message ?? e}'));
      });
    }
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _micTap() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path == null) return;
      try {
        final bytes = await File(path).readAsBytes();
        final b64 = base64Encode(bytes);
        final text = await ref.read(chatRepositoryProvider).transcribeWavBase64(b64);
        if (text.isNotEmpty) await _send(text);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('STT failed: $e')));
        }
      }
    } else {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/chat_stt.wav';
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: filePath,
        );
        setState(() => _recording = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth0 = ref.watch(auth0ServiceProvider);
    final t = ref.watch(authTokenProvider);
    final authed = t != null && t.isNotEmpty;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Stylist chat'),
        actions: [
          Switch(
            value: _voiceReply,
            onChanged: (v) async {
              setState(() => _voiceReply = v);
              await saveVoiceReplyEnabled(v);
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: Text('Voice')),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (!authed && auth0Configured())
            MaterialBanner(
              content: const Text('Sign in for a personalized experience (optional for anonymous API).'),
              actions: [
                TextButton(
                  onPressed: () async {
                    try {
                      await auth0?.login();
                      setState(() {});
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      }
                    }
                  },
                  child: const Text('Sign in'),
                ),
              ],
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _msgs.length,
              itemBuilder: (context, i) {
                final m = _msgs[i];
                return Align(
                  alignment: m.assistant ? Alignment.centerLeft : Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Card(
                      color: m.assistant ? null : Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(m.text),
                            if (m.outfits != null && m.outfits!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...m.outfits!.map((o) {
                                return ListTile(
                                  dense: true,
                                  title: Text('Suggestion · ${o['puntuacion']}'),
                                  trailing: TextButton(
                                    child: const Text('Save'),
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(outfitsRepositoryProvider)
                                            .save(buildSaveOutfitPayload(o));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Outfit saved')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('$e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_sending) const LinearProgressIndicator(),
          Row(
            children: [
              IconButton(
                icon: Icon(_recording ? Icons.stop_circle : Icons.mic_none),
                color: _recording ? Colors.red : null,
                onPressed: _sending ? null : _micTap,
              ),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(hintText: 'Message…'),
                  onSubmitted: _sending ? null : _send,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sending ? null : () => _send(_ctrl.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
