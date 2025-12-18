import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('1. 전선 허용전류 (Allowable Current)', () {
    test('Should calculate Iz correctly for given params', () {
      final params = CableCapacityParams(
        cableSizeSq: 4.0, // 4sq
        insulationType: InsulationType.xlpe,
        conductorType: ConductorType.copper,
        constructionCode: 'C', // 공사방법 C
        ambientTemperature: 30,
        conductorCount: 3,
      );

      final result = CableCapacityCalculator.calculate(params);

      // 4sq, XLPE(90도), 30도, C방법, 3가닥 -> Table spec check (approx 46A in table)
      expect(result.baseIz, greaterThanOrEqualTo(40));
      expect(result.adjustedIz, greaterThanOrEqualTo(40));
    });

    test('Should select correct minimum cable for target current', () {
      final params = CableCapacityParams(
        insulationType: InsulationType.pvc,
        conductorType: ConductorType.copper,
        constructionCode: 'A1',
        ambientTemperature: 30,
        conductorCount: 2, // 단상
      );

      // Target 20A.
      // 1.5sq PVC A1 2c -> 15.5A (Fail)
      // 2.5sq PVC A1 2c -> 21A (Pass)
      final result = CableCapacityCalculator.selectMinCableSize(
        targetCurrent: 20.0,
        params: params,
      );

      expect(result.cableSizeSq, equals(2.5));
      expect(result.adjustedIz, greaterThanOrEqualTo(20.0));
    });
  });
}
