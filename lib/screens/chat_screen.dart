import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../core/env.dart';
import '../providers/auth_token.dart';
import '../providers/repositories.dart';
import '../services/auth0_service.dart';
import '../theme/app_theme.dart';
import '../utils/mirror_context.dart';
import '../utils/outfit_recommend_query.dart';
import '../utils/save_outfit_payload.dart';
import '../widgets/sw_components.dart';

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
  String? _composerError;
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
      _composerError = null;
    });
    _ctrl.clear();
    _scrollBottom();

    try {
      final repo = ref.read(chatRepositoryProvider);
      final r = await repo.chat(trimmed);
      List<Map<String, dynamic>>? cards;
      if (r.outfitGeneration != null) {
        final q = outfitRecommendQuery(Map<String, dynamic>.from(r.outfitGeneration!));
        try {
          cards = await ref.read(outfitsRepositoryProvider).recommend(q);
        } catch (_) {
          cards = null;
        }
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
        _composerError = e.message ?? e.toString();
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
          setState(() => _composerError = 'STT failed: $e');
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

    if (auth0Configured() && !authed) {
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
                    const SwHeading('Stylist chat'),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to use chat with your profile.',
                      style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        try {
                          await auth0?.login();
                          if (mounted) setState(() {});
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                          }
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

    return Scaffold(
      backgroundColor: SwColors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SwPageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SwHeading('Stylist chat'),
                  SizedBox(height: 6),
                  Text(
                    'Ask for outfit ideas, edits, and shopping direction.',
                    style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SwPageContainer(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                itemCount: _msgs.length,
                itemBuilder: (context, i) {
                  final m = _msgs[i];
                  return Align(
                    alignment: m.assistant ? Alignment.centerLeft : Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: m.assistant ? Colors.white : SwColors.black,
                          border: Border.all(color: m.assistant ? SwColors.border : SwColors.black),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: m.assistant
                              ? const [
                                  BoxShadow(color: Color(0x12000000), offset: Offset(3, 3), blurRadius: 0),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              m.text,
                              style: TextStyle(
                                color: m.assistant ? SwColors.black : Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                            if (m.outfits != null && m.outfits!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ...m.outfits!.map((o) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SwCard(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Suggestion · ${o['puntuacion']}',
                                            style: const TextStyle(fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                        TextButton(
                                          child: const Text('SAVE'),
                                          onPressed: () async {
                                            try {
                                              await ref.read(outfitsRepositoryProvider).save(buildSaveOutfitPayload(o));
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
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              TextButton(
                                onPressed: () => context.go('/generate'),
                                child: const Text('OPEN GENERATE', style: TextStyle(fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_sending) const LinearProgressIndicator(),
          SwPageContainer(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.paddingOf(context).bottom),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SwColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_composerError != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: Text(_composerError!, style: const TextStyle(color: SwColors.accent, fontWeight: FontWeight.w700)),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Voice replies',
                          onPressed: () async {
                            final v = !_voiceReply;
                            setState(() => _voiceReply = v);
                            await saveVoiceReplyEnabled(v);
                          },
                          icon: Icon(_voiceReply ? Icons.volume_up : Icons.volume_off_outlined),
                        ),
                        IconButton(
                          icon: Icon(_recording ? Icons.stop_circle : Icons.mic_none),
                          color: _recording ? SwColors.accent : SwColors.black,
                          onPressed: _sending ? null : _micTap,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Message…',
                              border: InputBorder.none,
                            ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
