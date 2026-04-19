String? vitClassToTipoEs(Object? className) {
  if (className == null) return null;
  final s = className.toString().trim().toLowerCase();
  if (s.isEmpty) return null;

  const map = <String, String>{
    't-shirt': 'superior',
    'tshirt': 'superior',
    'top': 'superior',
    'trouser': 'inferior',
    'pants': 'inferior',
    'pullover': 'superior',
    'dress': 'vestido',
    'coat': 'abrigo',
    'sandal': 'zapatos',
    'sneaker': 'zapatos',
    'boot': 'zapatos',
    'shoe': 'zapatos',
    'bag': 'bolso',
    'ankle boot': 'zapatos',
    'shirt': 'superior',
  };

  return map[s];
}

bool isUnknownLabel(Object? value) {
  if (value == null) return true;
  final s = value.toString().trim().toLowerCase();
  return s.isEmpty || s == 'desconocido';
}

Map<String, dynamic> normalizeVitResponse(Map<String, dynamic> raw) {
  final rawTop3 = raw['top3'];
  final top3 = <Map<String, dynamic>>[];

  if (rawTop3 is List) {
    for (final pred in rawTop3) {
      if (pred is! Map) continue;
      final m = Map<String, dynamic>.from(pred as Map);
      if (m.containsKey('class_name') || m.containsKey('confidence') || m.containsKey('class_index')) {
        final inferredTipo = vitClassToTipoEs(m['class_name']);
        top3.add({
          ...m,
          'clase_nombre': m['clase_nombre'] ?? m['class_name'] ?? 'desconocido',
          'clase': m['clase'] ?? m['class_index'] ?? 0,
          'confianza': m['confianza'] ?? m['confidence'] ?? 0,
          'tipo': m['tipo'] ?? raw['tipo'] ?? inferredTipo ?? 'desconocido',
        });
      } else {
        top3.add(m);
      }
    }
  }

  final top1 = top3.isNotEmpty ? top3.first : null;
  final claseNombreFromTop1 = top1?['clase_nombre'];
  final confianzaFromTop1 = top1?['confianza'];
  final claseFromTop1 = top1?['clase'];
  final tipoFromTop1 = top1?['tipo'];

  final rawConfidence = raw['confianza'];
  final looksLikePlaceholderConfidence = rawConfidence is! num ||
      rawConfidence <= 0 ||
      rawConfidence > 1 ||
      (rawConfidence == 0.5 && isUnknownLabel(raw['clase_nombre']));

  final normalized = <String, dynamic>{
    ...raw,
    'top3': top3,
    'tipo': isUnknownLabel(raw['tipo']) ? (tipoFromTop1 ?? raw['tipo']) : raw['tipo'],
    'clase_nombre': !isUnknownLabel(raw['clase_nombre'])
        ? raw['clase_nombre']
        : (claseNombreFromTop1 ?? raw['clase_nombre']),
    'confianza': !looksLikePlaceholderConfidence
        ? raw['confianza']
        : (confianzaFromTop1 is num ? confianzaFromTop1 : raw['confianza']),
    'clase': (raw['clase'] is num && raw['clase'] != 0)
        ? raw['clase']
        : (claseFromTop1 is num ? claseFromTop1 : raw['clase']),
  };
  return normalized;
}
