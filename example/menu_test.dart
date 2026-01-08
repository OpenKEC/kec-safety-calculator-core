import 'dart:io';

import 'package:kec_safety_calculator_core/kec_calculator.dart';

/// 화면 지우기 함수
void clearScreen() {
  if (Platform.isWindows) {
    print('\n' * 50);
  } else {
    print('\x1B[2J\x1B[0;0H');
  }
}

// ====================================================
//  사용자 입력 헬퍼 함수
// ====================================================

double inputDouble(String label, [double defaultValue = 0.0]) {
  stdout.write('👉 $label (기본값: $defaultValue): ');
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return defaultValue;
  return double.tryParse(input) ?? defaultValue;
}

int inputInt(String label, [int defaultValue = 0]) {
  stdout.write('👉 $label (기본값: $defaultValue): ');
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return defaultValue;
  return int.tryParse(input) ?? defaultValue;
}

String inputString(String label, [String defaultValue = '']) {
  stdout.write('👉 $label (기본값: $defaultValue): ');
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return defaultValue;
  return input.trim();
}

T inputEnum<T>(String label, List<T> values, [T? defaultValue]) {
  print('\n[ $label 선택 ]');
  for (int i = 0; i < values.length; i++) {
    print('${i + 1}. ${values[i].toString().split('.').last}');
  }
  int defIdx = defaultValue != null ? values.indexOf(defaultValue) + 1 : 1;
  stdout.write('번호 선택 (기본값: $defIdx): ');
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    return defaultValue ?? values.first;
  }
  int? idx = int.tryParse(input);
  if (idx == null || idx < 1 || idx > values.length) {
    return defaultValue ?? values.first;
  }
  return values[idx - 1];
}

void main() async {
  while (true) {
    print('\n==================================================');
    print('   ⚡ KEC Safety Calculator Core - 대화형 테스트      ');
    print('==================================================');
    print('1. 🔌 허용전류 계산 (Cable Capacity)');
    print('2. 📉 전압강하 계산 (Voltage Drop)');
    print('3. 🛡️ 차단기 선정 (Breaker Selection)');
    print('4. ⚡ 단락전류 계산 (Short Circuit)');
    print('5. 🌍 접지선 굵기 (Earthing Size)');
    print('6. 🚇 전선관 굵기 (Conduit Size)');
    print('7. 🏗️ 통합 설계 (전체 프로세스)');
    print('8. 🏢 분전반 용량 검토 (Panel Capacity)');
    print('0. ❌ 종료 (Exit)');
    print('--------------------------------------------------');
    stdout.write('👉 메뉴 번호를 선택하세요: ');

    String? menu = stdin.readLineSync();
    clearScreen();

    try {
      switch (menu) {
        case '1':
          await _testCableCapacity();
          break;
        case '2':
          await _testVoltageDrop();
          break;
        case '3':
          await _testBreaker();
          break;
        case '4':
          await _testShortCircuit();
          break;
        case '5':
          await _testEarthing();
          break;
        case '6':
          await _testConduit();
          break;
        case '7':
          await _testIntegration();
          break;
        case '8':
          await _testPanelCapacity();
          break;
        case '0':
          print('프로그램을 종료합니다.');
          exit(0);
        default:
          print('⚠️ 잘못된 입력입니다.');
      }
    } catch (e) {
      print('\n❌ [에러 발생] 계산 중 오류가 났습니다.');
      print('에러 내용: $e');
    }

    print('\n(엔터를 누르면 메인 메뉴로 돌아갑니다)');
    stdin.readLineSync();
    clearScreen();
  }
}

// ====================================================
//  [1] 허용전류 계산 테스트
// ====================================================
Future<void> _testCableCapacity() async {
  print('\n--- [1] 허용전류 계산 (Cable Capacity) ---');

  double size = inputDouble('전선 굵기(sq)', 4.0);
  var insulation =
      inputEnum('절연체 종류', InsulationType.values, InsulationType.xlpe);
  var conductor =
      inputEnum('도체 재질', ConductorType.values, ConductorType.copper);
  String method = inputString('공사방법 코드 (예: A1, B1, C, E, F, G)', 'F');
  int temp = inputInt('주위 온도(°C)', 30);
  int circuits = inputInt('회로 수 (동일관/트레이 내)', 1);
  int cores = inputInt('도체 수 (단상:2, 3상:3)', 3);
  int parallel = inputInt('병렬 도체 수', 1);

  print('\n🔄 계산 중...');

  var params = CableCapacityParams(
    cableSizeSq: size,
    insulationType: insulation,
    conductorType: conductor,
    constructionCode: method,
    ambientTemperature: temp,
    numberOfCircuits: circuits,
    conductorCount: cores,
    parallelConductors: parallel,
  );

  var result = CableCapacityCalculator.calculate(params);
  print('\n✅ 계산 결과:');
  print(' - 기본 허용전류 (Iz_base): ${result.baseIz.toStringAsFixed(2)} A');
  print(' - 온도 보정계수 (k1): ${result.tempCorrectionFactor}');
  print(' - 집합 보정계수 (k2): ${result.groupingCorrectionFactor}');
  print(' - 최종 보정 허용전류: ${result.adjustedIz.toStringAsFixed(2)} A');
}

// ====================================================
//  [2] 전압강하 계산 테스트
// ====================================================
Future<void> _testVoltageDrop() async {
  print('\n--- [2] 전압강하 계산 (Voltage Drop) ---');

  double dist = inputDouble('전선 길이(L) [m]', 50.0);
  double current = inputDouble('부하 전류(I) [A]', 25.0);
  double size = inputDouble('전선 굵기 [sq]', 4.0);
  double voltage = inputDouble('선로 전압 [V]', 380.0);
  var wiring = inputEnum('배선 방식', WiringType.values, WiringType.threePhase);
  double pf = inputDouble('역률 (0.1 ~ 1.0)', 0.9);
  var conductor =
      inputEnum('도체 재질', ConductorType.values, ConductorType.copper);
  int parallel = inputInt('병렬 도체 수', 1);

  print('\n🔄 계산 중...');

  var params = VoltageDropParams(
    lengthInMeters: dist,
    loadCurrent: current,
    cableSizeSq: size,
    systemVoltage: voltage,
    wiringType: wiring,
    powerFactor: pf,
    conductorType: conductor,
    parallelConductors: parallel,
  );

  var result = VoltageDropCalculator.calculate(params);
  print('\n✅ 계산 결과:');
  print(' - 전압강하(e): ${result.dropVoltage.toStringAsFixed(2)} V');
  print(' - 전압강하율(%): ${result.dropPercent.toStringAsFixed(2)} %');
  print(' - 선로 저항: ${result.usedResistance.toStringAsFixed(5)} Ω/km');
  print(' - 선로 리액턴스: ${result.usedReactance.toStringAsFixed(5)} Ω/km');

  if (result.dropPercent > 3.0) {
    print('⚠️ [주의] 허용 기준(3%)을 초과하였습니다.');
  } else {
    print('🟢 [안전] 허용 기준 이내입니다.');
  }
}

// ====================================================
//  [3] 차단기 선정 테스트
// ====================================================
Future<void> _testBreaker() async {
  print('\n--- [3] 차단기 선정 (Breaker Selection) ---');

  double power = inputDouble('부하 용량', 15.0);
  String unit = inputString('용량 단위 (kW 또는 kVA)', 'kW');
  double voltage = inputDouble('선로 전압 [V]', 380.0);
  var wiring = inputEnum('배선 방식', WiringType.values, WiringType.threePhase);
  double pf = inputDouble('역률', 0.9);
  bool isMotor = inputString('전동기 부하입니까? (y/n)', 'n').toLowerCase() == 'y';
  var breakerType =
      inputEnum('차단기 종류', BreakerType.values, BreakerType.industrial);

  print('\n🔄 계산 중...');

  var params = DesignCurrentParams(
    capacity: power,
    capacityUnit: unit,
    systemVoltage: voltage,
    wiringType: wiring,
    powerFactor: pf,
    isMotorLoad: isMotor,
  );

  var result = BreakerCalculator.selectBreaker(
    params: params,
    breakerType: breakerType,
  );

  print('\n✅ 계산 결과:');
  print(' - 설계 전류 (Ib): ${result.designCurrent.toStringAsFixed(2)} A');
  if (isMotor) {
    print(
        ' - 전동기 기동 여유율 포함 Target: ${result.targetCurrent.toStringAsFixed(2)} A');
  }
  print(' - 최종 선정 차단기 정격 (In): ${result.selectedBreakerRating} A');
}

// ====================================================
//  [4] 단락전류 계산 테스트
// ====================================================
Future<void> _testShortCircuit() async {
  print('\n--- [4] 단락전류 계산 (Short Circuit) ---');
  print('💡 변압기 용량 기준 간이법(Transformer Method)');

  double kva = inputDouble('변압기 용량 [kVA]', 1000.0);
  double volt = inputDouble('2차측 전압 [V]', 380.0);
  double imp = inputDouble('퍼센트 임피던스 (%Z)', 5.0);

  print('\n🔄 계산 중...');

  double isCurrent = BreakerCalculator.calculateShortCircuitCurrent(
    kva: kva,
    voltage: volt,
    impedancePercent: imp,
  );

  print('\n✅ 계산 결과:');
  print(' - 추정 단락전류 (Is): ${isCurrent.toStringAsFixed(2)} kA');
  print(' ⚡ 주의: 실제 설계 시에는 선로 임피던스를 포함한 상세 계산이 필요할 수 있습니다.');
}

// ====================================================
//  [5] 접지선 굵기 테스트 (보호도체)
// ====================================================
Future<void> _testEarthing() async {
  print('\n--- [5] 접지선 굵기 (Earthing Size) ---');

  double isCurrent = inputDouble('예상 단락전류 [kA]', 5.0);
  double time = inputDouble('차단기 차단 시간 [sec]', 0.1);
  var insulation =
      inputEnum('접지선 절연체 종류', InsulationType.values, InsulationType.pvc);

  print('\n🔄 계산 중...');

  var params = ShortCircuitParams(
    shortCircuitCurrentKa: isCurrent,
    durationSeconds: time,
    insulationType: insulation,
  );

  var result = BreakerCalculator.checkShortCircuitSafety(params: params);

  print('\n✅ 계산 결과:');
  print(' - 적용 K 계수: ${result.kFactor}');
  print(' - 필요 최소 굵기: ${result.minCableSizeSq.toStringAsFixed(2)} sq');
  print(' - 권장 표준 굵기: 2.5 sq 이상 중 선택 (예: 6, 10, 16 sq 등)');
}

// ====================================================
//  [6] 전선관 굵기 테스트
// ====================================================
Future<void> _testConduit() async {
  print('\n--- [6] 전선관 굵기 (Conduit Size) ---');

  double mSize = inputDouble('메인 전선 굵기 [sq]', 4.0);
  int mCount = inputInt('메인 전선 가닥수', 3);
  var mType = inputEnum('메인 전선 타입', CableCoreType.values, CableCoreType.single);

  double eSize = inputDouble('접지선 굵기 [sq] (0 입력 시 없음)', 4.0);
  int eCount = eSize > 0 ? 1 : 0;

  print('\n🔄 계산 중...');

  var params = ConduitParams(
    mainWireSizeSq: mSize,
    mainWireCount: mCount,
    mainWireType: mType,
    earthWireSizeSq: eSize > 0 ? eSize : null,
    earthWireCount: eCount,
  );

  var result = ConduitCalculator.calculateDetailed(params);

  print('\n✅ 계산 결과:');
  print(' - 총 전선 단면적 점유량: ${result.totalWireArea.toStringAsFixed(2)} mm²');
  print('\n[ 추천 전선관 (점유율 32% 기준) ]');
  for (var rec in result.recommendations) {
    String status = rec.isSafe ? "🟢 양호" : "❌ 불가";
    print(
        ' • ${rec.typeLabel}: ${rec.size}호 (점유율 ${rec.occupancyRate.toStringAsFixed(1)}%) [$status]');
  }
  print('\n💡 팁: ${result.expertTip}');
}

// ====================================================
//  [7] 통합 설계 테스트
// ====================================================
Future<void> _testIntegration() async {
  print('\n--- [7] 통합 설계 (통합 서비스) ---');

  double power = inputDouble('부하 용량', 15.0);
  String unit = inputString('용량 단위 (kW/kVA)', 'kW');
  double dist = inputDouble('전선 길이 [m]', 50.0);
  double volt = inputDouble('선로 전압 [V]', 380.0);
  var wiring = inputEnum('배선 방식', WiringType.values, WiringType.threePhase);
  var method = inputString('공사방법 코드 (A1 ~ G)', 'C');
  var insulation =
      inputEnum('절연체 종류', InsulationType.values, InsulationType.xlpe);
  var conductor =
      inputEnum('도체 재질', ConductorType.values, ConductorType.copper);
  int temp = inputInt('주위 온도 [°C]', 30);
  bool isMotor = inputString('전동기 부하인가요? (y/n)', 'n').toLowerCase() == 'y';
  double pf = inputDouble('역률', 0.9);
  int parallel = inputInt('병렬 도체 수', 1);
  double ssc = inputDouble('예상 단락전류 [kA] (0 입력 시 생략)', 10.0);

  print('\n🔄 통합 프로세스 계산 중...');

  final input = KecCalculationInput(
    voltage: volt,
    loadCapacity: power,
    capacityUnit: unit,
    cableLength: dist,
    wiringMethod: wiring,
    conductorType: conductor,
    insulationType: insulation,
    constructionMethodCode: method,
    ambientTemperature: temp,
    breakerType: BreakerType.industrial,
    isMotor: isMotor,
    powerFactor: pf,
    numberOfCircuits: 1,
    parallelConductors: parallel,
    shortCircuitCurrent: ssc > 0 ? ssc : null,
    shortCircuitDuration: ssc > 0 ? 0.1 : null,
  );

  final result = await IntegratedKecService.calculate(input);

  print('\n============= [ 통합 설계 최종 결과 ] =============');
  print('🛠️ 최종 선정 전선 굵기 : ${result.finalCableSize} mm²');
  print('🛠️ 최종 선정 차단기 정격 : ${result.finalBreakerRating} A');
  print('--------------------------------------------------');
  print('📊 검토 항목별 최소 요구 굵기:');
  result.detailResults
      .forEach((k, v) => print(' - $k : $v ${v is num ? "sq" : ""}'));

  print('\n📜 상세 계산 근거:');
  for (var log in result.reasoning) {
    print(' • $log');
  }
  print('==================================================');
}

// ====================================================
//  [8] 분전반 용량 검토 테스트
// ====================================================
Future<void> _testPanelCapacity() async {
  print('\n--- [8] 분전반 용량 검토 (Panel Capacity) ---');

  double mainRating = inputDouble('메인 차단기 정격 (In) [A]', 100.0);
  double existingLoad = inputDouble('현재 사용 중인 부하 합계 [A]', 40.0);
  double newLoad = inputDouble('새로 추가할 부하 전류 [A]', 30.0);

  print('\n🔄 검토 중...');

  final result = PanelCalculator.checkCapacity(
    mainBreakerRating: mainRating,
    existingLoadCurrent: existingLoad,
    newLoadCurrent: newLoad,
  );

  print('\n✅ 검토 결과:');
  print(' - 증설 후 총 예상 부하: ${result.totalLoadCurrent.toStringAsFixed(1)} A');
  print(' - 여유 용량: ${result.marginCurrent.toStringAsFixed(1)} A');

  if (result.isSafe) {
    print('🟢 [설치 가능] 메인 차단기 용량이 충분합니다.');
  } else {
    print('❌ [설치 불가] 메인 차단기 용량이 부족합니다! 차단기 교체 또는 부하 조정이 필요합니다.');
  }
}
