import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  group('7. 분전반 증설 (Panel Capacity)', () {
    test('Safe Condition', () {
      final result = PanelCalculator.checkCapacity(
        mainBreakerRating: 50,
        existingLoadCurrent: 20,
        newLoadCurrent: 20, // Total 40 <= 50
      );

      expect(result.isSafe, isTrue);
      expect(result.marginCurrent, equals(10.0)); // 50 - 40
    });

    test('Unsafe Condition', () {
      final result = PanelCalculator.checkCapacity(
        mainBreakerRating: 30,
        existingLoadCurrent: 20,
        newLoadCurrent: 15, // Total 35 > 30
      );

      expect(result.isSafe, isFalse);
      expect(result.marginCurrent, equals(-5.0));
      expect(result.resultMessage, contains('Unsafe'));
    });
  });
}
