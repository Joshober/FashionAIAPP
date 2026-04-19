/// Normalize populated or partial outfit maps for `POST /api/outfits/save`.
Map<String, dynamic> buildSaveOutfitPayload(Map<String, dynamic> outfit) {
  String? idOf(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    if (v is Map) {
      final id = v['_id'] ?? v['id'];
      if (id != null) return id.toString();
    }
    return null;
  }

  return {
    if (idOf(outfit['superior_id']) != null) 'superior_id': idOf(outfit['superior_id']),
    if (idOf(outfit['inferior_id']) != null) 'inferior_id': idOf(outfit['inferior_id']),
    if (idOf(outfit['zapatos_id']) != null) 'zapatos_id': idOf(outfit['zapatos_id']),
    if (idOf(outfit['abrigo_id']) != null) 'abrigo_id': idOf(outfit['abrigo_id']),
    if (idOf(outfit['vestido_id']) != null) 'vestido_id': idOf(outfit['vestido_id']),
    if (outfit['puntuacion'] is num) 'puntuacion': (outfit['puntuacion'] as num).toDouble(),
    if (outfit['explicacion'] is String) 'explicacion': outfit['explicacion'],
  };
}
