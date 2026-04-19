import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dio_client.dart';
import '../theme/app_theme.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/sw_components.dart';

class ModelExamplesScreen extends ConsumerStatefulWidget {
  const ModelExamplesScreen({super.key});

  @override
  ConsumerState<ModelExamplesScreen> createState() => _ModelExamplesScreenState();
}

class _ModelExamplesScreenState extends ConsumerState<ModelExamplesScreen> {
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await ref.read(dioProvider).get<Map<String, dynamic>>('/api/model/data-audit');
      setState(() {
        _data = r.data;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      appBar: AppBar(title: const Text('Model examples')),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            color: SwColors.light,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwLabel('Model audit'),
                SizedBox(height: 8),
                SwDisplay(['DATA', 'CARDS']),
              ],
            ),
          ),
          const MarqueeStrip(labels: ['CNN', 'VIT', 'STREET EDITION', 'FASHION AI']),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SwPageContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    SwCard(child: Text(_error!, style: const TextStyle(color: SwColors.accent, fontWeight: FontWeight.w700)))
                  else
                    SwCard(
                      child: SelectableText(
                        _data?.toString() ?? 'Loading…',
                        style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SwCard(
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SwLabel('Classifier'),
                              SizedBox(height: 8),
                              Text('CNN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              SizedBox(height: 6),
                              Text('Fast garment routing.', style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SwCard(
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SwLabel('Classifier'),
                              SizedBox(height: 8),
                              Text('ViT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              SizedBox(height: 6),
                              Text('High-accuracy vision features.', style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
