import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('5. 접지선 굵기 (Earthing)', () {
    test('Should match KEC 142.3.2 simple rule', () {
      // S <= 16 -> S
      expect(EarthingCalculator.calculateMinSize(10), equals(10));
      expect(EarthingCalculator.calculateMinSize(16), equals(16));

      // 16 < S <= 35 -> 16
      expect(EarthingCalculator.calculateMinSize(25), equals(16));
      expect(EarthingCalculator.calculateMinSize(35), equals(16));

      // S > 35 -> S/2
      expect(EarthingCalculator.calculateMinSize(50), equals(25));
      expect(EarthingCalculator.calculateMinSize(70), equals(35));
    });
  });
}
