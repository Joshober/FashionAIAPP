import 'package:fashion_ai/utils/classification_display.dart';
import 'package:fashion_ai/utils/classification_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classification display mapping', () {
    test('typeToEnglish maps known values', () {
      expect(typeToEnglish('superior'), 'TOP');
      expect(typeToEnglish('desconocido'), 'UNKNOWN');
    });

    test('colorToEnglish maps known values', () {
      expect(colorToEnglish('azul'), 'Blue');
      expect(colorToEnglish('desconocido'), 'Unknown');
    });

    test('garmentClassLabel handles unknown and underscores', () {
      expect(garmentClassLabel('desconocido'), 'Unknown');
      expect(garmentClassLabel('Ankle_boot'), 'Ankle boot');
    });

    test('formatOccasionsEnglish formats lists and comma strings', () {
      expect(formatOccasionsEnglish(['casual', 'trabajo']), 'Casual, Work');
      expect(formatOccasionsEnglish('deportivo,fiesta'), 'Sporty, Party');
      expect(formatOccasionsEnglish(null), '\u2014');
    });
  });

  group('classification response normalization', () {
    test('normalizeVitResponse derives top-level values from top3 shape', () {
      final out = normalizeVitResponse({
        'tipo': 'desconocido',
        'clase_nombre': 'desconocido',
        'confianza': 0.5,
        'top3': [
          {'class_name': 'Ankle_boot', 'class_index': 9, 'confidence': 0.91}
        ],
      });

      expect(out['tipo'], 'zapatos');
      expect(out['clase_nombre'], 'Ankle_boot');
      expect(out['confianza'], 0.91);
      expect(out['clase'], 9);
    });
  });
}
