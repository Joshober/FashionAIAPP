import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../utils/mirror_context.dart';
import '../widgets/sw_components.dart';

class MirrorScreen extends ConsumerStatefulWidget {
  const MirrorScreen({super.key});

  @override
  ConsumerState<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends ConsumerState<MirrorScreen> {
  CameraController? _cam;
  bool _camOn = false;
  bool _busy = false;
  bool _live = false;
  Map<String, dynamic>? _lastClassify;
  Map<String, dynamic>? _lastMirror;
  List<int>? _lastJpeg;
  String _weatherStatus = 'Set location in Mirror context';
  String _contextSummary = 'Loading context…';

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
    if (c.style.trim().isNotEmpty) bits.add(c.style.trim());
    if (c.location.trim().isNotEmpty) bits.add(c.location.trim());
    setState(() {
      _contextSummary = bits.isEmpty ? 'No context saved yet.' : bits.join(' · ');
      if (c.location.trim().isNotEmpty) {
        _weatherStatus = 'Context: ${c.location.trim()}';
      }
    });
  }

  Future<void> _startCam() async {
    final list = await availableCameras();
    if (list.isEmpty) return;
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
  }

  Future<void> _stopCam() async {
    final c = _cam;
    setState(() {
      _cam = null;
      _camOn = false;
      _live = false;
    });
    await c?.dispose();
  }

  @override
  void dispose() {
    _cam?.dispose();
    super.dispose();
  }

  Future<void> _captureAndClassify() async {
    final c = _cam;
    if (c == null || !c.value.isInitialized) return;
    setState(() => _busy = true);
    try {
      final shot = await c.takePicture();
      final bytes = await shot.readAsBytes();
      _lastJpeg = bytes;
      final b64 = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$b64';
      final ctx = await loadMirrorContext();
      final mirror = await ref.read(mirrorRepositoryProvider).analyzeFrame(dataUrl, ctx.toJson());
      final vit = await ref.read(garmentsRepositoryProvider).classifyVitBase64(dataUrl);
      setState(() {
        _lastMirror = mirror;
        _lastClassify = vit;
        _busy = false;
      });
    } catch (e) {
      setState(() => _busy = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _addToWardrobe() async {
    final bytes = _lastJpeg;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture and classify first')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(garmentsRepositoryProvider).upload(bytes, 'mirror.jpg');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to wardrobe')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _cam;
    return Scaffold(
      backgroundColor: SwColors.white,
      body: SwPageContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const SwHeading('Mirror'),
            const SizedBox(height: 6),
            const Text(
              'Real-time AI feedback on what you are wearing.',
              style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 14),
            SwCard(
              child: Row(
                children: [
                  const Icon(Icons.cloud_outlined, color: SwColors.black),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_weatherStatus, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _weatherStatus = 'Refresh: use Mirror context for weather text');
                    },
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
                        child: Text(_camOn ? 'STOP CAMERA' : 'START CAMERA', style: const TextStyle(fontWeight: FontWeight.w900)),
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
                        child: c != null && c.value.isInitialized
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(c),
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
                    alignment: WrapAlignment.start,
                    children: [
                      FilledButton(
                        onPressed: (_busy || !_camOn) ? null : _captureAndClassify,
                        child: const Text('EVALUATE OUTFIT'),
                      ),
                      OutlinedButton(
                        onPressed: (_busy || !_camOn) ? null : _captureAndClassify,
                        child: const Text('CLASSIFY VIT'),
                      ),
                      OutlinedButton(
                        onPressed: (_busy || !_camOn) ? null : _captureAndClassify,
                        child: const Text('CLASSIFY + STYLIST'),
                      ),
                      FilterChip(
                        label: Text(_live ? 'LIVE ON' : 'LIVE OFF'),
                        selected: _live,
                        onSelected: (v) {
                          if (!_camOn) return;
                          setState(() => _live = v);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(v ? 'Live mode stub on' : 'Live mode off')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_lastClassify != null) ...[
              const SizedBox(height: 12),
              SwCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SwLabel('ViT detection'),
                    const SizedBox(height: 8),
                    Text(
                      '${_lastClassify!['tipo']} · ${_lastClassify!['clase_nombre']} · ${_lastClassify!['color']}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(onPressed: _addToWardrobe, child: const Text('ADD TO WARDROBE')),
                  ],
                ),
              ),
            ],
            if (_lastMirror != null) ...[
              const SizedBox(height: 12),
              SwCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SwLabel('Stylist advice'),
                    const SizedBox(height: 8),
                    Text(
                      'Score ${_lastMirror!['score']} · ${_lastMirror!['summary']}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
          ],
        ),
      ),
    );
  }
}
