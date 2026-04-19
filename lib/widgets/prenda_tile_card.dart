import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Garment grid tile: 4/5 image, category badge, footer (PrendaCard parity).
class PrendaTileCard extends StatelessWidget {
  const PrendaTileCard({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.subtitle,
    required this.onTap,
    this.onEditOccasion,
    this.onDelete,
  });

  final String imageUrl;
  final String category;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onEditOccasion;
  final VoidCallback? onDelete;

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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: imageUrl.isEmpty
                            ? Container(color: SwColors.light)
                            : Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: SwColors.black,
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      if (onEditOccasion != null || onDelete != null)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onEditOccasion != null)
                                _RoundIcon(icon: Icons.edit_calendar_outlined, onTap: onEditOccasion!),
                              if (onDelete != null) ...[
                                const SizedBox(width: 6),
                                _RoundIcon(icon: Icons.delete_outline, onTap: onDelete!, danger: true),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: SwColors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap, this.danger = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: danger ? SwColors.accent : SwColors.black),
        ),
      ),
    );
  }
}
