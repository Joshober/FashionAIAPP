import '../core/media_url.dart';

/// Ordered garment slots for outfit preview collages.
List<dynamic> outfitPieceRefsInOrder(Map<String, dynamic> o) {
  return [
    o['superior_id'],
    o['inferior_id'],
    o['zapatos_id'],
    o['abrigo_id'],
    o['vestido_id'],
  ];
}

List<String> outfitImageUrls(String apiBase, Map<String, dynamic> o) {
  final urls = <String>[];
  for (final ref in outfitPieceRefsInOrder(o)) {
    if (ref is Map) {
      final u = resolveMediaUrl(apiBase, ref['imagen_url']?.toString());
      if (u.isNotEmpty) urls.add(u);
    }
  }
  return urls;
}
