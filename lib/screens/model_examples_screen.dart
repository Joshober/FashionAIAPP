import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dio_client.dart';
import '../widgets/app_drawer.dart';

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
      appBar: AppBar(title: const Text('Model examples')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _error != null
            ? Text(_error!)
            : SelectableText(_data?.toString() ?? 'Loading…'),
      ),
    );
  }
}
