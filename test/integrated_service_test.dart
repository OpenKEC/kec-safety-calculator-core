import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('IntegratedKecService 통합 테스트', () {
    test('일반 부하(히터) 시나리오 검증 (15kW, 380V, 50m)', () async {
      final input = KecCalculationInput(
        voltage: 380,
        loadCapacity: 15,
        capacityUnit: 'kW',
        cableLength: 50,
        wiringMethod: WiringType.threePhase,
        conductorType: ConductorType.copper,
        insulationType: InsulationType.xlpe,
        constructionMethodCode: 'C', // 기중
        ambientTemperature: 30,
        breakerType: BreakerType.industrial,
        isMotor: false,
        powerFactor: 1.0,
      );

      final result = await IntegratedKecService.calculate(input);

      // Ib = 15000 / (sqrt(3) * 380 * 1.0) = 22.79A
      // In = 30A (standard industrial breaker >= 22.79A)
      // S_B = 2.5sq (XLPE Method C 3-core Iz=30A, but let's check constants)
      // S_CB = 4.0sq (XLPE Method C 3-core Iz=40A >= 30A)

      expect(result.finalBreakerRating, 30);
      expect(result.finalCableSize, greaterThanOrEqualTo(4.0));
      expect(result.reasoning.length, greaterThan(5));
      expect(result.detailResults.containsKey('S_B (설계전류)'), true);
    });

    test('전동기 부하 시나리오 검증 (7.5kW, 380V, 30m)', () async {
      final input = KecCalculationInput(
        voltage: 380,
        loadCapacity: 7.5,
        capacityUnit: 'kW',
        cableLength: 30,
        wiringMethod: WiringType.threePhase,
        conductorType: ConductorType.copper,
        insulationType: InsulationType.xlpe,
        constructionMethodCode: 'F', // Tray
        ambientTemperature: 30,
        breakerType: BreakerType.industrial,
        isMotor: true,
        powerFactor: 0.85,
        motorStartingMultiplier: 1.5, // 차단기 여유율
      );

      final result = await IntegratedKecService.calculate(input);

      // Ib = 7500 / (sqrt(3) * 380 * 0.85) = 13.41A
      // Target = 13.41 * 1.5 = 20.11A
      // In = 30A (or 20A? Industrial standard: 15, 20, 30...)
      // In should be >= 20.11 -> 30A

      expect(result.finalBreakerRating, 30);
      expect(result.detailResults['S_MSTH (기동열적)'], isNot('N/A'));
    });
  });
}
