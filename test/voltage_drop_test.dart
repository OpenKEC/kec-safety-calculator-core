import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('3. 전압강하 계산 (Voltage Drop)', () {
    test('Single Phase Calculation', () {
      // 단상 220V, 부하 50A, 거리 100m, 16sq, 구리
      final params = VoltageDropParams(
        systemVoltage: 220,
        loadCurrent: 50,
        lengthInMeters: 100,
        wiringType: WiringType.singlePhase,
        conductorType: ConductorType.copper,
        cableSizeSq: 16.0,
        powerFactor: 1.0,
      );

      final result = VoltageDropCalculator.calculate(params);

      // e = 2 * I * L * (R*1 + X*0) / 1000
      // 16sq Cu R approx 1.15 ohm/km
      // e = 2 * 50 * 0.1 * 1.15 = 11.5 V
      // % = 11.5 / 220 = 5.2%

      expect(result.dropVoltage, closeTo(11.5, 2.0)); // 허용오차 2V
      expect(result.dropPercent, closeTo(5.2, 1.0));
    });

    test('Three Phase Calculation', () {
      // 3상 380V, 부하 50A, 거리 100m, 16sq
      final params = VoltageDropParams(
        systemVoltage: 380,
        loadCurrent: 50,
        lengthInMeters: 100,
        wiringType: WiringType.threePhase, // 3상
        conductorType: ConductorType.copper,
        cableSizeSq: 16.0,
        powerFactor: 1.0,
      );

      final result = VoltageDropCalculator.calculate(params);

      // e = √3 * I * L * R / 1000
      // e = 1.732 * 50 * 0.1 * 1.15 = 9.96 V
      // % = 9.96 / 380 = 2.6%

      expect(result.dropVoltage, closeTo(9.96, 2.0));
      expect(result.dropPercent, closeTo(2.6, 1.0));
    });
  });
}
