import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../utils/save_outfit_payload.dart';
import '../widgets/outfit_rich_card.dart';
import '../widgets/sw_components.dart';

class GenerateOutfitDetailScreen extends ConsumerStatefulWidget {
  const GenerateOutfitDetailScreen({super.key, required this.outfit});

  final Map<String, dynamic>? outfit;

  @override
  ConsumerState<GenerateOutfitDetailScreen> createState() => _GenerateOutfitDetailScreenState();
}

class _GenerateOutfitDetailScreenState extends ConsumerState<GenerateOutfitDetailScreen> {
  bool _saving = false;
  bool _shareBusy = false;

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
    setState(() => _saving = true);
    try {
      final body = buildSaveOutfitPayload(o);
      await ref.read(outfitsRepositoryProvider).save(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to wardrobe')));
        context.go('/wardrobe/outfits');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _shareStub() async {
    setState(() => _shareBusy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _shareBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share: hook platform share next')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.outfit;
    if (o == null) {
      return const Scaffold(
        backgroundColor: SwColors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final base = ref.watch(apiBaseUrlProvider);
    return Scaffold(
      backgroundColor: SwColors.white,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/generate')),
        title: const Text('Suggestion'),
        actions: [
          TextButton(
            onPressed: () => context.go('/wardrobe/outfits'),
            child: const Text('SAVED', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: SwPageContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SwLabel('Suggestion'),
            const SizedBox(height: 10),
            OutfitRichCard(apiBase: base, outfit: o),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('SAVE OUTFIT'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _shareBusy ? null : _shareStub,
              child: Text(_shareBusy ? 'PREPARING…' : 'SHARE IMAGE'),
            ),
          ],
        ),
      ),
    );
  }
}
