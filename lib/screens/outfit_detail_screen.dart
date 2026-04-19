import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/api_base.dart';
import '../providers/repositories.dart';
import '../theme/app_theme.dart';
import '../widgets/outfit_rich_card.dart';
import '../widgets/sw_components.dart';

class OutfitDetailScreen extends ConsumerStatefulWidget {
  const OutfitDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends ConsumerState<OutfitDetailScreen> {
  Map<String, dynamic>? _o;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final o = await ref.read(outfitsRepositoryProvider).get(widget.id);
      setState(() {
        _o = o;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = ref.watch(apiBaseUrlProvider);
    return Scaffold(
      backgroundColor: SwColors.white,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/wardrobe/outfits')),
        title: const Text('Outfit'),
        actions: [
          TextButton(
            onPressed: () => context.go('/generate'),
            child: const Text('GENERATE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: SwPageContainer(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: SwCard(child: Text(_error!)))
                : _o == null
                    ? const SizedBox.shrink()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          const SwLabel('Outfit'),
                          const SizedBox(height: 10),
                          OutfitRichCard(apiBase: base, outfit: _o!),
                        ],
                      ),
      ),
    );
  }
}
