import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  test('최소 전선 굵기 제한 (2.5sq) 검증 테스트', () async {
    // 0.5kW(약 2.3A)의 아주 작은 부하 설정 (원래는 1.5sq로 충분한 조건)
    final input = KecCalculationInput(
      voltage: 220.0,
      loadCapacity: 0.5,
      capacityUnit: 'kW',
      cableLength: 10.0,
      wiringMethod: WiringType.singlePhase,
      conductorType: ConductorType.copper,
      insulationType: InsulationType.xlpe,
      constructionMethodCode: 'A1',
      ambientTemperature: 30,
      breakerType: BreakerType.residential,
      isMotor: false,
      powerFactor: 1.0,
    );

    final result = await IntegratedKecService.calculate(input);

    print('\n[검증 결과]');
    print('설계전류: ${result.finalBreakerRating}A (차단기 정격 기준)');
    print('최종 선정 굵기: ${result.finalCableSize}sq');

    // 검증: 1.5sq가 리스트에 없으므로 최소 2.5sq가 나와야 함
    expect(result.finalCableSize, greaterThanOrEqualTo(2.5));
    expect(result.finalCableSize, isNot(1.5));
  });
}
