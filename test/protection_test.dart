import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('4. 단락전류 및 차단기 선정 (Protection)', () {
    test('Breaker Selection (Ib <= In)', () {
      final params = const DesignCurrentParams(
        capacity: 10, // 10kW
        capacityUnit: 'kW',
        systemVoltage: 220, // 단상 220V
        wiringType: WiringType.singlePhase,
        powerFactor: 1.0,
      );

      // I = 10000 / 220 = 45.45 A
      final result = BreakerCalculator.selectBreaker(
          params: params,
          breakerType: BreakerType.residential // 주택용 (10,15,20...40,50)
          );

      expect(result.designCurrent, closeTo(45.45, 0.1));
      expect(result.selectedBreakerRating, equals(50)); // 40A 다음 50A
    });

    test('Short Circuit Current Calculation (Impedance method)', () {
      // 1000kVA, 380V, %Z=5.0
      // In = 1000000 / (1.732 * 380) = 1519.3 A
      // Is = (100/5) * 1519.3 = 20 * 1519.3 = 30386 A = 30.38 kA
      final isKA = BreakerCalculator.calculateShortCircuitCurrent(
        kva: 1000,
        voltage: 380,
        impedancePercent: 5.0,
      );

      expect(isKA, closeTo(30.38, 0.5));
    });

    test('Short Circuit Safety Check (Min Size)', () {
      // 30kA, 0.03sec, XLPE(k=143)
      // MinS = (I*√t)/k = (30000 * √0.03) / 143
      // = (30000 * 0.1732) / 143 = 5196 / 143 = 36.33 sq
      final result = BreakerCalculator.checkShortCircuitSafety(
        params: const ShortCircuitParams(
          shortCircuitCurrentKa: 30.0,
          durationSeconds: 0.03,
          insulationType: InsulationType.xlpe,
        ),
        checkCableSizeSq: 35.0, // Check 35sq
      );

      expect(result.minCableSizeSq, closeTo(36.3, 1.0));
      expect(result.isSafe, isFalse); // 35sq < 36.33sq -> Unsafe
    });
  });
}
