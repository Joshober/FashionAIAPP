import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Uppercase metadata label (`.sw-label`).
class SwLabel extends StatelessWidget {
  const SwLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
        color: color ?? SwColors.accent,
      ),
    );
  }
}

/// Heavy display title (`.sw-display`).
class SwDisplay extends StatelessWidget {
  const SwDisplay(this.lines, {super.key});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Text(
            line.toUpperCase(),
            style: const TextStyle(
              fontSize: 34,
              height: 0.92,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: SwColors.black,
            ),
          ),
      ],
    );
  }
}

/// Section heading (`.sw-heading`).
class SwHeading extends StatelessWidget {
  const SwHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
        color: SwColors.black,
      ),
    );
  }
}

class SwSectionRow extends StatelessWidget {
  const SwSectionRow({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: SwHeading(title)),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}

/// Bordered white card (`.sw-card`).
class SwCard extends StatelessWidget {
  const SwCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SwColors.border),
        borderRadius: BorderRadius.circular(2),
        boxShadow: onTap != null
            ? const [
                BoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: card,
      ),
    );
  }
}

/// Dashed empty state (guide §5).
class SwEmptyState extends StatelessWidget {
  const SwEmptyState({super.key, required this.title, this.subtitle, this.actionLabel, this.onAction});

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(color: SwColors.border.withValues(alpha: 0.9)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
        child: Column(
          children: [
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8, color: SwColors.black),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: SwColors.gray, fontWeight: FontWeight.w600),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!.toUpperCase())),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dash = 7.0;
    const gap = 5.0;

    void dashedLine(Offset a, Offset b) {
      final dir = (b - a);
      final len = dir.distance;
      if (len == 0) return;
      final unit = dir / len;
      double t = 0;
      var draw = true;
      while (t < len) {
        final step = draw ? dash : gap;
        final t2 = (t + step).clamp(0, len);
        if (draw) canvas.drawLine(a + unit * t, a + unit * t2, paint);
        t = t2;
        draw = !draw;
      }
    }

    dashedLine(rect.topLeft, rect.topRight);
    dashedLine(rect.topRight, rect.bottomRight);
    dashedLine(rect.bottomRight, rect.bottomLeft);
    dashedLine(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Filter chip: active = black / white text.
class SwFilterChip extends StatelessWidget {
  const SwFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? SwColors.black : Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: SwColors.border, width: 1),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 0.9,
            color: selected ? Colors.white : SwColors.black,
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable chip row with hidden scrollbar (guide §6).
class SwChipScroller extends StatelessWidget {
  const SwChipScroller({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemBuilder: (_, i) => children[i],
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: children.length,
        ),
      ),
    );
  }
}

/// Primary content width cap (~ `max-w-7xl`).
class SwPageContainer extends StatelessWidget {
  const SwPageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: child,
      ),
    );
  }
}

String garmentFilterLabel(String tipo) {
  switch (tipo) {
    case 'all':
      return 'All';
    case 'superior':
      return 'Top';
    case 'inferior':
      return 'Bottom';
    case 'zapatos':
      return 'Shoes';
    case 'abrigo':
      return 'Coat';
    case 'vestido':
      return 'Dress';
    default:
      return tipo;
  }
}
