import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  print('=== KEC Safety Calculator Core Demo ===\n');

  // 1. 입력 조건 설정 (Input Conditions)
  const double loadKw = 15.0; // 15kW
  const double voltage = 380.0;
  const double lengthMeters = 50.0;
  const WiringType wiring = WiringType.threePhase;
  const InsulationType insulation = InsulationType.xlpe;
  const ConductorType conductor = ConductorType.copper;
  const String constructionMethod = 'C'; // 표면 노출 (C)

  print(
      '[Input] $loadKw kW, $voltage V, L=$lengthMeters m, Method=$constructionMethod');

  // 2. 설계 전류 계산 및 차단기 선정 (Protection Module)
  final designParams = DesignCurrentParams(
    capacity: loadKw,
    capacityUnit: 'kW',
    systemVoltage: voltage,
    wiringType: wiring,
    powerFactor: 0.9, // 역률 90%
    isMotorLoad: false,
  );

  final breakerResult = BreakerCalculator.selectBreaker(
    params: designParams,
    breakerType: BreakerType.industrial, // MCCB
  );

  print('\n[Step 1] Breaker Selection');
  print(
      ' - Design Current (Ib): ${breakerResult.designCurrent.toStringAsFixed(2)} A');
  print(
      ' - Target Current (Im): ${breakerResult.targetCurrent.toStringAsFixed(2)} A');
  print(' - Selected Breaker (In): ${breakerResult.selectedBreakerRating} A');

  // 3. 케이블 굵기 선정 (Cable Module)
  // 조건: 허용전류(Iz) >= 차단기 정격(In) (과부하 보호)
  final cableParams = CableCapacityParams(
    insulationType: insulation,
    conductorType: conductor,
    constructionCode: constructionMethod,
    ambientTemperature: 30, // 30도
    conductorCount: 3, // 3상 3선
  );

  final cableResult = CableCapacityCalculator.selectMinCableSize(
    targetCurrent: breakerResult.selectedBreakerRating.toDouble(),
    params: cableParams,
  );

  print('\n[Step 2] Cable Selection (Capacity)');
  print(
      ' - Min Size for In(${breakerResult.selectedBreakerRating}A): ${cableResult.cableSizeSq} mm²');
  print(' - Adjusted Iz: ${cableResult.adjustedIz.toStringAsFixed(2)} A');

  // 4. 전압강하 검토 (Voltage Drop Module)
  final dropParams = VoltageDropParams(
    systemVoltage: voltage,
    loadCurrent: breakerResult.designCurrent, // 부하전류 기준
    lengthInMeters: lengthMeters,
    wiringType: wiring,
    conductorType: conductor,
    cableSizeSq: cableResult.cableSizeSq, // 선정된 굵기로 검토
    powerFactor: 0.9,
  );

  final dropResult = VoltageDropCalculator.calculate(dropParams);

  print('\n[Step 3] Voltage Drop Check');
  print(' - Used Cable: ${dropParams.cableSizeSq} mm²');
  print(' - Voltage Drop: ${dropResult.dropVoltage.toStringAsFixed(2)} V');
  print(' - Drop Percent: ${dropResult.dropPercent.toStringAsFixed(2)} %');

  if (dropResult.dropPercent > 3.0) {
    print(' -> WARNING: Voltage drop exceeds 3%!');
  } else {
    print(' -> OK: Voltage drop is within limit.');
  }

  // 5. 단락 안전성 검토 (Optional)
  final shortCircuitParams = ShortCircuitParams(
    shortCircuitCurrentKa: 5.0, // 5kA 가정
    durationSeconds: 0.1, // 0.1s 차단 시간
    insulationType: insulation,
  );

  final scResult = BreakerCalculator.checkShortCircuitSafety(
    params: shortCircuitParams,
    checkCableSizeSq: cableResult.cableSizeSq,
  );

  print('\n[Step 4] Short Circuit Check');
  print(
      ' - Min Size for 5kA/0.1s: ${scResult.minCableSizeSq.toStringAsFixed(2)} mm²');
  print(
      ' - Is Selected Cable (${cableResult.cableSizeSq} mm²) Safe? ${scResult.isSafe}');

  print('\n=== Calculation Complete ===');
}
