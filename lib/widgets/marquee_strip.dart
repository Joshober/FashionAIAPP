import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Black ticker strip with repeated labels (Dashboard marquee).
class MarqueeStrip extends StatefulWidget {
  const MarqueeStrip({super.key, this.labels = const ['STREET EDITION', 'FASHION AI', 'WARDROBE', 'MIRROR']});

  final List<String> labels;

  @override
  State<MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<MarqueeStrip> {
  final _scroll = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (max <= 0) return;
      var next = _scroll.offset + 0.6;
      if (next >= max) next = 0;
      _scroll.jumpTo(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parts = <Widget>[];
    for (var i = 0; i < 24; i++) {
      for (final l in widget.labels) {
        parts.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              l.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
          ),
        );
        parts.add(
          const Text('·', style: TextStyle(color: SwColors.accent, fontWeight: FontWeight.w900, fontSize: 14)),
        );
      }
    }

    return Container(
      height: 44,
      color: SwColors.black,
      child: ListView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: parts,
      ),
    );
  }
}
