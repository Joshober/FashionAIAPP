/// Turn a relative `/uploads/...` path into a loadable URL for [Image.network].
String resolveMediaUrl(String apiBase, String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = apiBase.endsWith('/') ? apiBase.substring(0, apiBase.length - 1) : apiBase;
  final p = path.startsWith('/') ? path : '/$path';
  return '$base$p';
}
