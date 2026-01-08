import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('2. 전선 굵기 선정 통합 (Integration)', () {
    // 시나리오:
    // 3상 380V, 50kW 부하, 거리 100m, 차단기 100A 선정됨.
    // 1) 허용전류 만족?
    // 2) 전압강하 3% 이내 만족?
    // -> 최종 굵기 산출

    test('Full Selection Flow', () {
      // 1. 설계 전류 & 차단기
      const double loadKw = 50.0;
      const double voltage = 380.0;

      // Ib = 50000 / (1.732 * 380) = 75.9 A
      final designParams = const DesignCurrentParams(
        capacity: loadKw,
        capacityUnit: 'kW',
        systemVoltage: voltage,
        wiringType: WiringType.threePhase,
        powerFactor: 1.0,
      );

      final breakerResult = BreakerCalculator.selectBreaker(
        params: designParams,
        breakerType: BreakerType.industrial,
      );
      // In should be >= 75.9 A -> likely 75A or 100A (depending on list).
      // If list has 75, it picks 75. (75 < 75.9 is false, so next is 100)
      // Actually standard list: ..., 60, 75, 100 ...
      // If 75.9A, then 75 is too small. Must be 100A.
      expect(breakerResult.selectedBreakerRating, equals(100));

      // 2. 케이블 허용전류 (In 이상이어야 함)
      final cableParams = const CableCapacityParams(
        insulationType: InsulationType.xlpe,
        conductorType: ConductorType.copper,
        constructionCode: 'C', // 트레이/노출
        ambientTemperature: 30,
        conductorCount: 3,
      );

      final capResult = CableCapacityCalculator.selectMinCableSize(
        targetCurrent: 100.0,
        params: cableParams,
      );
      // 16sq (Iz=~110) or similar.
      final sizeForIz = capResult.cableSizeSq;
      expect(sizeForIz, greaterThanOrEqualTo(16.0));

      // 3. 전압강하 (3% 이내)
      // Check if sizeForIz satisfies VD
      final vdParams = VoltageDropParams(
        systemVoltage: voltage,
        loadCurrent: 75.9, // Use Ib for VD
        lengthInMeters: 100.0,
        wiringType: WiringType.threePhase,
        conductorType: ConductorType.copper,
        cableSizeSq: sizeForIz,
        powerFactor: 1.0,
      );

      VoltageDropResult vdResult = VoltageDropCalculator.calculate(vdParams);

      // If drop > 3%, try next sizes
      double finalSize = sizeForIz;
      if (vdResult.dropPercent > 3.0) {
        // Simple loop simulation for test
        final standardSizes = [16.0, 25.0, 35.0, 50.0];
        for (final s in standardSizes) {
          if (s <= sizeForIz) continue;
          final newParams = VoltageDropParams(
              systemVoltage: voltage,
              loadCurrent: 75.9,
              lengthInMeters: 100,
              wiringType: WiringType.threePhase,
              conductorType: ConductorType.copper,
              cableSizeSq: s,
              powerFactor: 1.0);
          final res = VoltageDropCalculator.calculate(newParams);
          if (res.dropPercent <= 3.0) {
            finalSize = s;
            break;
          }
        }
      }

      // Expected result:
      // 100m is long. 16sq might have high drop.
      // e = 1.732 * 75.9 * 0.1 * R(1.15) / 1000?? No formula is 1/1000 applied to L?
      // L=100m -> 0.1km.
      // e = 1.732 * 76 * 0.1 * 1.15 = 15V.
      // 15/380 = 3.9% -> Fail 3%.
      // Need larger cable. 25sq?
      // R(25) = ~0.727
      // e = 1.732 * 76 * 0.1 * 0.727 = 9.5V
      // 9.5/380 = 2.5% -> Pass.

      // So final size should be likely 25sq or more.
      expect(finalSize, greaterThanOrEqualTo(25.0));
    });
  });
}
