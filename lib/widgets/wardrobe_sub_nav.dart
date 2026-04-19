import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'sw_components.dart';

/// Garments / Saved outfits chip row.
class WardrobeSubNav extends StatelessWidget {
  const WardrobeSubNav({super.key, required this.garmentsSelected});

  final bool garmentsSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SwFilterChip(
            label: 'Garments',
            selected: garmentsSelected,
            onTap: () => context.go('/wardrobe'),
          ),
          const SizedBox(width: 10),
          SwFilterChip(
            label: 'Saved outfits',
            selected: !garmentsSelected,
            onTap: () => context.go('/wardrobe/outfits'),
          ),
        ],
      ),
    );
  }
}
