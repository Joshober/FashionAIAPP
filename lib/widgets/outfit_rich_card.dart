import 'package:flutter/material.dart';

import '../core/media_url.dart';
import '../theme/app_theme.dart';

/// Rich outfit card (OutfitCard parity) for saved / generated detail views.
class OutfitRichCard extends StatelessWidget {
  const OutfitRichCard({
    super.key,
    required this.apiBase,
    required this.outfit,
    this.explanationExpanded = true,
  });

  final String apiBase;
  final Map<String, dynamic> outfit;
  final bool explanationExpanded;

  List<Widget> _pieces() {
    Widget? piece(String label, dynamic ref) {
      if (ref == null) return null;
      if (ref is! Map) return null;
      final url = resolveMediaUrl(apiBase, ref['imagen_url']?.toString());
      return SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: SwColors.gray,
              ),
            ),
            const SizedBox(height: 6),
            AspectRatio(
              aspectRatio: 3 / 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: SwColors.border),
                  color: SwColors.light,
                ),
                child: url.isEmpty
                    ? const Center(child: Icon(Icons.checkroom_outlined))
                    : Image.network(url, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${ref['tipo']} · ${ref['clase_nombre']}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return [
      piece('Top', outfit['superior_id']),
      piece('Pullover', outfit['pullover_id']),
      piece('Bottom', outfit['inferior_id']),
      piece('Shoes', outfit['zapatos_id']),
      piece('Coat', outfit['abrigo_id']),
      piece('Dress', outfit['vestido_id']),
    ].whereType<Widget>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final score = outfit['puntuacion']?.toString() ?? '—';
    final expl = outfit['explicacion']?.toString() ?? '';
    final pieces = _pieces();
    final body = pieces.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No garment images embedded in this outfit payload.',
              style: TextStyle(color: SwColors.gray, fontWeight: FontWeight.w700),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < pieces.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  pieces[i],
                ],
              ],
            ),
          );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SwColors.border),
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: SwColors.black,
                child: Text(
                  'SCORE $score',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          body,
          if (expl.isNotEmpty) ...[
            const SizedBox(height: 14),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: explanationExpanded,
                tilePadding: EdgeInsets.zero,
                title: const Text(
                  'SEE WHY IT MATCHES',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6, fontSize: 12),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(expl, style: const TextStyle(color: SwColors.black, height: 1.35)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
