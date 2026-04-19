import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repositories.dart';
import '../utils/mirror_context.dart';
import '../widgets/app_drawer.dart';

class MirrorScreen extends ConsumerStatefulWidget {
  const MirrorScreen({super.key});

  @override
  ConsumerState<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends ConsumerState<MirrorScreen> {
  CameraController? _cam;
  bool _busy = false;
  Map<String, dynamic>? _lastClassify;
  Map<String, dynamic>? _lastMirror;
  List<int>? _lastJpeg;

  @override
  void initState() {
    super.initState();
    _initCam();
  }

  Future<void> _initCam() async {
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
    setState(() => _cam = ctrl);
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
    final cls = _lastClassify;
    if (bytes == null || cls == null) {
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
      appBar: AppBar(title: const Text('Mirror')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: c == null || !c.value.isInitialized
                ? const Center(child: Text('Starting camera…'))
                : CameraPreview(c),
          ),
          if (_busy) const LinearProgressIndicator(),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              FilledButton(
                onPressed: _busy ? null : _captureAndClassify,
                child: const Text('Capture & analyze'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : _addToWardrobe,
                child: const Text('Add to wardrobe'),
              ),
            ],
          ),
          if (_lastClassify != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('ViT: ${_lastClassify!['tipo']} · ${_lastClassify!['clase_nombre']} · ${_lastClassify!['color']}'),
            ),
          if (_lastMirror != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Mirror score: ${_lastMirror!['score']} · ${_lastMirror!['summary']}'),
            ),
        ],
      ),
    );
  }
}
