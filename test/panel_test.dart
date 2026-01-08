import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';
import 'package:kec_safety_calculator_core/src/panel/panel_calculator.dart'; // Import LoadType

void main() {
  group('7. 분전반 증설 (Panel Capacity)', () {
    group('checkPanelSafety', () {
      test('Safe Condition', () {
        final result = PanelCalculator.checkPanelSafety(
          mainBreakerRating: 50,
          cableAmpacity: 60, // Cable > Breaker (Safe)
          existingLoadCurrent: 20,
          newLoadCurrent: 20, // Total 40 <= 50 (Safe)
        );

        expect(result.isSafe, isTrue);
        expect(result.isHardwareSafe, isTrue);
        expect(result.marginCurrent, equals(10.0)); // 50 - 40
      });

      test('Hardware Mismatch (Breaker > Cable)', () {
        final result = PanelCalculator.checkPanelSafety(
          mainBreakerRating: 100,
          cableAmpacity: 50, // Breaker > Cable (Unsafe)
          existingLoadCurrent: 10,
          newLoadCurrent: 10,
        );

        expect(result.isHardwareSafe, isFalse);
        expect(result.isSafe, isFalse);
        expect(result.resultMessage, contains('Hardware Mismatch'));
      });

      test('Overload Condition (Total > Breaker)', () {
        final result = PanelCalculator.checkPanelSafety(
          mainBreakerRating: 30,
          cableAmpacity: 40,
          existingLoadCurrent: 20,
          newLoadCurrent: 15, // Total 35 > 30 (Unsafe)
        );

        expect(result.isBreakerSafe, isFalse);
        expect(result.isSafe, isFalse);
        expect(result.marginCurrent, equals(-5.0));
      });
    });

    group('checkBranchSafety', () {
      test('Branch Safe Condition', () {
        // Load: 10A, Motor (x1.25) -> Need 12.5A
        // Breaker: 20A (> 12.5A) -> OK
        // Cable: 30A (> 20A) -> OK
        final result = PanelCalculator.checkBranchSafety(
          newLoadCurrent: 10,
          loadType: LoadType.motor,
          branchBreakerRating: 20,
          branchCableAmpacity: 30,
        );

        expect(result.isSafe, isTrue);
        expect(result.isBreakerSafe, isTrue);
        expect(result.isCableSafe, isTrue);
      });

      test('Branch Breaker Too Small', () {
        // Load: 20A, Motor (x1.25) -> Need 25A
        // Breaker: 20A (< 25A) -> NG
        final result = PanelCalculator.checkBranchSafety(
          newLoadCurrent: 20,
          loadType: LoadType.motor,
          branchBreakerRating: 20,
          branchCableAmpacity: 30,
        );

        expect(result.isBreakerSafe, isFalse);
        expect(result.isSafe, isFalse);
      });

      test('Branch Cable Too Small', () {
        // Breaker: 50A
        // Cable: 40A (< 50A) -> NG
        final result = PanelCalculator.checkBranchSafety(
          newLoadCurrent: 10,
          loadType: LoadType.resistive,
          branchBreakerRating: 50,
          branchCableAmpacity: 40,
        );

        expect(result.isCableSafe, isFalse);
        expect(result.isSafe, isFalse);
      });
    });
  });
}
