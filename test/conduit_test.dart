import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('6. 전선관 굵기 (Conduit)', () {
    test('Should recommend appropriate conduit sizes', () {
      // Main: 4sq 3c (CV) -> OD appx 12.5mm
      // Area: 3 * (12.5/2)^2 * pi = 3 * 39 * 3.14 / 4?? No OD is diameter.
      // Area = 3 * (12.5^2 * pi / 4) = 3 * 122.6 = 368 sqmm

      // Safe Inner Area >= 368 / 0.32 = 1150 sqmm
      // Sqrt(1150 * 4 / pi) = Sqrt(1465) = 38.2 mm ID required

      final result = ConduitCalculator.calculateDetailed(ConduitParams(
        mainWireSizeSq: 4.0,
        mainWireCount: 3,
        mainWireType: CableCoreType.multi, // CV cable has larger OD
      ));

      // HI-PVC
      // 36호(ID 35mm) -> Area ~962 -> Fail
      // 42호(ID 40mm) -> Area ~1256 -> Pass
      final pvc = result.recommendations
          .firstWhere((r) => r.typeLabel.contains('HI-PVC'));

      expect(pvc.size, greaterThanOrEqualTo(42));
      expect(pvc.isSafe, isTrue);
    });
  });
}
