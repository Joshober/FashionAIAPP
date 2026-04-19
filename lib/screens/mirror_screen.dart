import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../utils/classification_display.dart';
import '../utils/classification_normalize.dart';
import '../utils/mirror_context.dart';
import '../widgets/sw_components.dart';

class MirrorScreen extends ConsumerStatefulWidget {
  const MirrorScreen({super.key});

  @override
  ConsumerState<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends ConsumerState<MirrorScreen> {
  CameraController? _cam;
  Timer? _liveTimer;

  bool _camOn = false;
  bool _analyzing = false;
  bool _classifying = false;
  bool _stylistBusy = false;
  bool _addBusy = false;
  bool _live = false;

  String? _error;
  String _weatherStatus = 'Set location in Mirror context';
  String _contextSummary = 'Loading context...';

  Map<String, dynamic>? _lastClassify;
  Map<String, dynamic>? _lastMirror;
  String? _stylistAdvice;
  List<int>? _lastJpeg;
  MirrorContext _ctx = const MirrorContext();

  @override
  void initState() {
    super.initState();
    _hydrateContext();
  }

  Future<void> _hydrateContext() async {
    final c = await loadMirrorContext();
    if (!mounted) return;

    final bits = <String>[];
    if (c.occasion.trim().isNotEmpty) bits.add(c.occasion.trim());
    if (c.weather.trim().isNotEmpty) bits.add(c.weather.trim());
    if (c.time.trim().isNotEmpty) bits.add(c.time.trim());
    if (c.style.trim().isNotEmpty) bits.add(c.style.trim());
    if (c.location.trim().isNotEmpty) bits.add(c.location.trim());

    setState(() {
      _ctx = c;
      _contextSummary = bits.isEmpty ? 'No context saved yet.' : bits.join(' · ');
      _weatherStatus = c.location.trim().isNotEmpty
          ? 'Context: ${c.location.trim()}'
          : (c.weather.trim().isNotEmpty ? c.weather.trim() : 'Set location in Mirror context');
    });
  }

  Map<String, dynamic> _contextPayload() {
    final out = <String, dynamic>{
      'event': _ctx.occasion,
      'weather': _ctx.weather,
      'time': _ctx.time,
      'user_profile': {'style_preference': _ctx.style},
    };
    if (_ctx.location.trim().isNotEmpty) out['location'] = _ctx.location.trim();
    return out;
  }

  Future<void> _startCam() async {
    setState(() => _error = null);
    try {
      final list = await availableCameras();
      if (list.isEmpty) {
        setState(() => _error = 'No camera available on this device.');
        return;
      }

      CameraDescription pick = list.first;
      for (final c in list) {
        if (c.lensDirection == CameraLensDirection.front) {
          pick = c;
          break;
        }
      }

      final ctrl = CameraController(pick, ResolutionPreset.medium, enableAudio: false);
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }

      setState(() {
        _cam = ctrl;
        _camOn = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not start camera: $e');
    }
  }

  Future<void> _stopCam() async {
    _liveTimer?.cancel();
    _liveTimer = null;

    final c = _cam;
    setState(() {
      _cam = null;
      _camOn = false;
      _live = false;
    });
    await c?.dispose();
  }

  Future<String?> _captureFrameDataUrl() async {
    final c = _cam;
    if (c == null || !c.value.isInitialized) return null;

    final shot = await c.takePicture();
    final bytes = await shot.readAsBytes();
    _lastJpeg = bytes;
    final b64 = base64Encode(bytes);
    return 'data:image/jpeg;base64,$b64';
  }

  Future<Map<String, dynamic>> _classifyCurrentFrame() async {
    final dataUrl = await _captureFrameDataUrl();
    if (dataUrl == null) {
      throw StateError('Camera not ready. Start camera and try again.');
    }

    final raw = await ref.read(garmentsRepositoryProvider).classifyVitBase64(dataUrl);
    return normalizeVitResponse(raw);
  }

  Future<void> _analyzeFrame() async {
    if (_analyzing || !_camOn) return;
    setState(() {
      _analyzing = true;
      _error = null;
      _stylistAdvice = null;
    });

    try {
      final dataUrl = await _captureFrameDataUrl();
      if (dataUrl == null) {
        throw StateError('Camera not ready. Start camera and try again.');
      }

      final mirror = await ref.read(mirrorRepositoryProvider).analyzeFrame(
            dataUrl,
            _contextPayload(),
            userNotes: _ctx.notes,
          );
      if (!mounted) return;
      setState(() => _lastMirror = mirror);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _classifyVit() async {
    if (_classifying || !_camOn) return;
    setState(() {
      _classifying = true;
      _error = null;
      _stylistAdvice = null;
    });

    try {
      final vit = await _classifyCurrentFrame();
      if (!mounted) return;
      setState(() => _lastClassify = vit);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _classifying = false);
    }
  }

  Future<void> _classifyAndStylist() async {
    if (_stylistBusy || !_camOn) return;
    setState(() {
      _stylistBusy = true;
      _error = null;
      _stylistAdvice = null;
    });

    try {
      final vit = await _classifyCurrentFrame();
      if (mounted) setState(() => _lastClassify = vit);

      final summary = [
        'I just captured a photo from the Mirror. The classifier analyzed the image.',
        'Main prediction: ${garmentClassLabel(vit['clase_nombre'])} - garment type: ${typeToEnglish(vit['tipo'])}, color signal: ${colorToEnglish(vit['color'])}.',
        '',
        'Mirror context for what I am dressing for:',
        '- Occasion: ${_ctx.occasion.isEmpty ? '—' : _ctx.occasion}',
        '- Weather: ${_ctx.weather.isEmpty ? '—' : _ctx.weather}',
        '- Time of day: ${_ctx.time.isEmpty ? '—' : _ctx.time}',
        if (_ctx.location.trim().isNotEmpty) '- Location: ${_ctx.location.trim()}',
        '- Style preference: ${_ctx.style.isEmpty ? '—' : _ctx.style}',
        if (_ctx.notes.trim().isNotEmpty) '- My notes: ${_ctx.notes.trim()}',
        '',
        'You do not have the photo - only this machine classification. Tell me what works and what specific changes could improve this look for the occasion.',
      ].join('\n');

      final chat = await ref.read(chatRepositoryProvider).chat(summary);
      if (!mounted) return;
      if (chat.reply.trim().isEmpty) {
        setState(() => _error = 'Empty response from stylist chat.');
      } else {
        setState(() => _stylistAdvice = chat.reply.trim());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _stylistBusy = false);
    }
  }

  Future<void> _addToWardrobe() async {
    final bytes = _lastJpeg;
    final vit = _lastClassify;
    if (bytes == null || vit == null) {
      setState(() => _error = 'Capture and classify first.');
      return;
    }

    setState(() {
      _addBusy = true;
      _error = null;
    });

    try {
      await ref.read(garmentsRepositoryProvider).autoSave({
        'imagen_base64': base64Encode(bytes),
        'tipo': vit['tipo']?.toString() ?? 'superior',
        'color': vit['color']?.toString() ?? 'desconocido',
        'clase_nombre': vit['clase_nombre']?.toString() ?? 'desconocido',
        'confianza': vit['confianza'] is num ? vit['confianza'] : 0.5,
        'ocasion': const <String>[],
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to wardrobe')));
      setState(() => _lastClassify = null);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _addBusy = false);
    }
  }

  void _toggleLive(bool value) {
    if (!_camOn) return;
    _liveTimer?.cancel();
    _liveTimer = null;

    setState(() => _live = value);
    if (!value) return;

    _liveTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_camOn || _analyzing || _stylistBusy) return;
      _analyzeFrame();
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classify = _lastClassify;
    final mirror = _lastMirror;
    final analysis = mirror?['analysis'];

    return Scaffold(
      backgroundColor: SwColors.white,
      body: SwPageContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SwHeading('Mirror'),
            const SizedBox(height: 6),
            const Text(
              'Get AI feedback on your outfit in real time.',
              style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 14),
            SwCard(
              child: Row(
                children: [
                  const Icon(Icons.cloud_outlined, color: SwColors.black),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _weatherStatus,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: _hydrateContext,
                    child: const Text('REFRESH'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          await context.push('/mirror/context');
                          await _hydrateContext();
                        },
                        child: const Text('CONTEXT', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _camOn ? _stopCam : _startCam,
                        child: Text(
                          _camOn ? 'STOP CAMERA' : 'START CAMERA',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _contextSummary,
                    style: const TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: ColoredBox(
                        color: SwColors.black,
                        child: _cam != null && _cam!.value.isInitialized
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(_cam!),
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: FilledButton.tonal(
                                      onPressed: () async {
                                        await context.push('/mirror/context');
                                        await _hydrateContext();
                                      },
                                      child: const Text('CTX'),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text(
                                  'Camera preview',
                                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: (_analyzing || !_camOn) ? null : _analyzeFrame,
                        child: Text(_analyzing ? 'EVALUATING...' : 'EVALUATE OUTFIT'),
                      ),
                      OutlinedButton(
                        onPressed: (_classifying || !_camOn) ? null : _classifyVit,
                        child: Text(_classifying ? 'CLASSIFYING...' : 'CLASSIFY VIT'),
                      ),
                      OutlinedButton(
                        onPressed: (_stylistBusy || !_camOn) ? null : _classifyAndStylist,
                        child: Text(_stylistBusy ? 'ASKING STYLIST...' : 'CLASSIFY + STYLIST'),
                      ),
                      FilterChip(
                        label: Text(_live ? 'LIVE ON' : 'LIVE OFF'),
                        selected: _live,
                        onSelected: _toggleLive,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              SwCard(
                child: Text(
                  _error!,
                  style: const TextStyle(color: SwColors.accent, fontWeight: FontWeight.w700),
                ),
              ),
            ],
            if (classify != null) ...[
              const SizedBox(height: 12),
              SwCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SwLabel('Detected (ViT)'),
                    const SizedBox(height: 8),
                    Text(
                      garmentClassLabel(classify['clase_nombre']),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${typeToEnglish(classify['tipo'])} · ${colorToEnglish(classify['color'])}',
                      style: const TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: _addBusy ? null : _addToWardrobe,
                      child: Text(_addBusy ? 'ADDING...' : 'ADD TO WARDROBE'),
                    ),
                  ],
                ),
              ),
            ],
            if (_stylistAdvice != null && _stylistAdvice!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SwCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SwLabel('Wardrobe stylist'),
                    const SizedBox(height: 8),
                    Text(
                      _stylistAdvice!,
                      style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => context.push('/chat'),
                      child: const Text('CONTINUE TO CHAT'),
                    ),
                  ],
                ),
              ),
            ],
            if (mirror != null) ...[
              const SizedBox(height: 12),
              SwCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SwLabel('Mirror analysis'),
                    const SizedBox(height: 8),
                    if (analysis is Map)
                      Text(
                        '${analysis['style_identity'] ?? 'Style insight'} · score ${analysis['overall_score'] ?? '—'}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      )
                    else
                      Text(
                        'Score ${mirror['score'] ?? '—'} · ${mirror['summary'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      analysis is Map
                          ? (analysis['expert_feedback']?.toString() ?? '')
                          : (mirror['summary']?.toString() ?? ''),
                      style: const TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
