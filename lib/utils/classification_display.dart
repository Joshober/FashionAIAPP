/// Maps ML-service labels to user-facing English labels for UI parity with the web app.
String typeToEnglish(Object? raw) {
  if (raw == null) return '';
  final value = raw.toString().trim();
  if (value.isEmpty) return '';

  const map = <String, String>{
    'superior': 'TOP',
    'inferior': 'BOTTOM',
    'zapatos': 'SHOES',
    'abrigo': 'COAT',
    'vestido': 'DRESS',
    'bolso': 'BAG',
    'accesorio': 'ACCESSORY',
    'joyeria': 'JEWELRY',
    'joyer\u00eda': 'JEWELRY',
    'sombrero': 'HAT',
    'cinturon': 'BELT',
    'cintur\u00f3n': 'BELT',
    'gafas': 'GLASSES',
    'desconocido': 'UNKNOWN',
  };

  final key = value.toLowerCase();
  return map[key] ?? value.replaceAll('_', ' ').toUpperCase();
}

String colorToEnglish(Object? raw) {
  if (raw == null) return '';
  final value = raw.toString().trim();
  if (value.isEmpty) return '';

  const map = <String, String>{
    'desconocido': 'Unknown',
    'negro': 'Black',
    'blanco': 'White',
    'gris': 'Gray',
    'rojo': 'Red',
    'rojo oscuro': 'Dark red',
    'azul': 'Blue',
    'azul oscuro': 'Dark blue',
    'verde': 'Green',
    'verde oscuro': 'Dark green',
    'amarillo': 'Yellow',
    'amarillo oscuro': 'Dark yellow',
    'naranja': 'Orange',
    'rosa': 'Pink',
    'beige': 'Beige',
    'marron': 'Brown',
    'marr\u00f3n': 'Brown',
    'magenta': 'Magenta',
    'multicolor': 'Multicolor',
  };

  final key = value.toLowerCase();
  return map[key] ?? value;
}

String garmentClassLabel(Object? raw) {
  if (raw == null) return 'Unknown';
  final value = raw.toString().trim();
  if (value.isEmpty) return 'Unknown';
  if (value.toLowerCase() == 'desconocido') return 'Unknown';
  return value.replaceAll('_', ' ');
}

String occasionToEnglish(Object? raw) {
  if (raw == null) return '';
  final value = raw.toString().trim();
  if (value.isEmpty) return '';

  const map = <String, String>{
    'casual': 'Casual',
    'formal': 'Formal',
    'deportivo': 'Sporty',
    'fiesta': 'Party',
    'trabajo': 'Work',
  };

  final key = value.toLowerCase();
  return map[key] ?? value.replaceAll('_', ' ');
}

String formatOccasionsEnglish(Object? raw) {
  const dash = '\u2014';
  if (raw == null) return dash;

  final items = <String>[];
  if (raw is List) {
    for (final v in raw) {
      final s = v.toString().trim();
      if (s.isNotEmpty) items.add(s);
    }
  } else {
    items.addAll(
      raw
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty),
    );
  }

  if (items.isEmpty) return dash;
  return items.map(occasionToEnglish).join(', ');
}
