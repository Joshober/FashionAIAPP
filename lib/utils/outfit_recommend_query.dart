/// Single source of truth for turning UI preferences into `/api/outfits/recommend` query params.
Map<String, String> outfitRecommendQuery(
  Map<String, dynamic>? preferences, {
  Set<String> excludeKeys = const {},
}) {
  final prefs = preferences ?? {};
  final out = <String, String>{};
  void put(String k, dynamic v) {
    if (excludeKeys.contains(k)) return;
    if (v == null) return;
    final s = v.toString().trim();
    if (s.isEmpty) return;
    out[k] = s;
  }

  put('style_preference', prefs['style_preference']);
  put('formality', prefs['formality']);
  put('palette', prefs['palette']);
  put('climate', prefs['climate']);
  put('notes', prefs['notes']);
  put('avoid', prefs['avoid']);
  return out;
}
