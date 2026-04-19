import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repositories.dart';
import '../utils/save_outfit_payload.dart';
import '../widgets/app_drawer.dart';

class GenerateOutfitDetailScreen extends ConsumerStatefulWidget {
  const GenerateOutfitDetailScreen({super.key, required this.outfit});

  final Map<String, dynamic>? outfit;

  @override
  ConsumerState<GenerateOutfitDetailScreen> createState() => _GenerateOutfitDetailScreenState();
}

class _GenerateOutfitDetailScreenState extends ConsumerState<GenerateOutfitDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.outfit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/generate');
      });
    }
  }

  Future<void> _save() async {
    final o = widget.outfit;
    if (o == null) return;
    try {
      final body = buildSaveOutfitPayload(o);
      await ref.read(outfitsRepositoryProvider).save(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to wardrobe')));
        context.go('/wardrobe/outfits');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.outfit;
    if (o == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Generated outfit')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Score: ${o['puntuacion']}', style: Theme.of(context).textTheme.headlineSmall),
            Text(o['explicacion']?.toString() ?? ''),
            const Spacer(),
            FilledButton(onPressed: _save, child: const Text('Save to wardrobe')),
            OutlinedButton(
              onPressed: () => context.go('/generate'),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
