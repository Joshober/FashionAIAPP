import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Compact collage preview for saved / recommended outfits.
class SavedOutfitGridCard extends StatelessWidget {
  const SavedOutfitGridCard({
    super.key,
    required this.imageUrls,
    required this.scoreLabel,
    required this.onTap,
    this.onDelete,
    this.footerActionLabel,
    this.onFooterAction,
  });

  final List<String> imageUrls;
  final String scoreLabel;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? footerActionLabel;
  final VoidCallback? onFooterAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: SwColors.border),
            borderRadius: BorderRadius.circular(2),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), offset: Offset(3, 3), blurRadius: 0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(child: _Collage(urls: imageUrls)),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: SwColors.black,
                              child: Text(
                                scoreLabel.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            if (onDelete != null) ...[
                              const SizedBox(width: 6),
                              Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                child: IconButton(
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  onPressed: onDelete,
                                  icon: const Icon(Icons.close, color: SwColors.black),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (footerActionLabel != null && onFooterAction != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                  child: OutlinedButton(
                    onPressed: onFooterAction,
                    child: Text(footerActionLabel!.toUpperCase()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Collage extends StatelessWidget {
  const _Collage({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final u = urls.where((e) => e.isNotEmpty).take(4).toList();
    if (u.isEmpty) return Container(color: SwColors.light);
    if (u.length == 1) {
      return Image.network(u.first, fit: BoxFit.cover);
    }
    if (u.length == 2) {
      return Row(
        children: [
          Expanded(child: Image.network(u[0], fit: BoxFit.cover)),
          Expanded(child: Image.network(u[1], fit: BoxFit.cover)),
        ],
      );
    }
    if (u.length == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: Image.network(u[0], fit: BoxFit.cover)),
                Expanded(child: Image.network(u[1], fit: BoxFit.cover)),
              ],
            ),
          ),
          Expanded(child: Image.network(u[2], fit: BoxFit.cover)),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.network(u[0], fit: BoxFit.cover)),
              Expanded(child: Image.network(u[1], fit: BoxFit.cover)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.network(u[2], fit: BoxFit.cover)),
              Expanded(child: Image.network(u[3], fit: BoxFit.cover)),
            ],
          ),
        ),
      ],
    );
  }
}
