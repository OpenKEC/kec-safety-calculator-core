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

/// 사용자 입력 받기 헬퍼 함수
double inputDouble(String label, [double defaultValue = 0.0]) {
  stdout.write('$label (기본값: $defaultValue): ');
  String? input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return defaultValue;
  return double.tryParse(input) ?? defaultValue;
}

void main() async {
  while (true) {
    print('\n==================================================');
    print('   ⚡ KEC Safety Calculator Core - 통합 테스트 (Real)   ');
    print('==================================================');
    print('1. 🔌 허용전류 계산 (Cable Capacity)');
    print('2. 📉 전압강하 계산 (Voltage Drop)');
    print('3. 🛡️ 차단기 선정 (Breaker Selection)');
    print('4. ⚡ 단락전류 계산 (Short Circuit)');
    print('5. 🌍 접지선 굵기 (Earthing Size)');
    print('6. 🚇 전선관 굵기 (Conduit Size)');
    print('7. 🏗️ 통합 설계 (전체 프로세스)');
    print('0. ❌ 종료 (Exit)');
    print('--------------------------------------------------');
    stdout.write('👉 메뉴 번호를 선택하세요: ');

    String? menu = stdin.readLineSync();
    clearScreen();

    try {
      switch (menu) {
        case '1': await _testCableCapacity(); break;
        case '2': await _testVoltageDrop(); break;
        case '3': await _testBreaker(); break;
        case '4': await _testShortCircuit(); break;
        case '5': await _testEarthing(); break;
        case '6': await _testConduit(); break;
        case '7': await _testIntegration(); break;
        case '0':
          print('프로그램을 종료합니다.');
          exit(0);
        default:
          print('⚠️ 잘못된 입력입니다.');
      }
    } catch (e, stack) {
      print('\n❌ [에러 발생] 계산 중 오류가 났습니다.');
      print('에러 내용: $e');
      print('스택 트레이스: $stack');
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
  print('📝 조건: TFR-CV(XLPE), 1C, 3상, 공사방법 F(Tray) 가정');

  double size = inputDouble('👉 전선 굵기(sq) 입력', 4.0);
  double temp = inputDouble('👉 주위 온도(°C) 입력', 30.0);

  print('\n🔄 계산 중 (Real Core Logic)...');

  // 실제 로직 호출
  var params = CableCapacityParams(
    cableSizeSq: size,
    insulationType: InsulationType.xlpe,
    conductorType: ConductorType.copper,
    constructionCode: 'F', // Tray
    ambientTemperature: temp.toInt(),
    numberOfCircuits: 1,
    conductorCount: 1, // Single core
    parallelConductors: 1,
  );

  try {
    var result = CableCapacityCalculator.calculate(params);
    print('✅ 계산된 허용전류: ${result.adjustedIz.toStringAsFixed(2)} A');
    print('   - 기본 허용전류: ${result.baseIz} A');
    print('   - 온도 보정계수: ${result.tempCorrectionFactor}');
    print('   - 집합 보정계수: ${result.groupingCorrectionFactor}');
  } catch (e) {
    print('❌ 계산 실패: $e');
  }
}

// ====================================================
//  [2] 전압강하 계산 테스트
// ====================================================
Future<void> _testVoltageDrop() async {
  print('\n--- [2] 전압강하 계산 (Voltage Drop) ---');
  
  double dist = inputDouble('👉 전선 길이(L) [m]', 50.0);
  double current = inputDouble('👉 부하 전류(I) [A]', 25.0);
  double size = inputDouble('👉 전선 굵기(A) [sq]', 4.0);

  print('\n🔄 계산 중 (Real Core Logic)...');

  var params = VoltageDropParams(
    lengthInMeters: dist,
    loadCurrent: current,
    cableSizeSq: size,
    systemVoltage: 380, // Default 380V (3상)
    wiringType: WiringType.threePhase,
    powerFactor: 0.9,
    conductorType: ConductorType.copper,
    parallelConductors: 1,
    resistancePerKm: null, // Auto lookup
    reactancePerKm: null, // Auto lookup
  );

  try {
    var result = VoltageDropCalculator.calculate(params);
    print('✅ 전압강하: ${result.dropVoltage.toStringAsFixed(2)} V');
    print('✅ 전압강하율: ${result.dropPercent.toStringAsFixed(2)} %');
    if (result.dropPercent > 3.0) {
      print('⚠️ [경고] 허용 기준 3% 초과!');
    } else {
      print('🟢 [양호] 허용 기준 3% 이내');
    }
  } catch (e) {
    print('❌ 계산 실패: $e');
  }
}

// ====================================================
//  [3] 차단기 선정 테스트
// ====================================================
Future<void> _testBreaker() async {
  print('\n--- [3] 차단기 선정 (Breaker Selection) ---');
  print('📝 입력: 부하 용량을 입력하면 설계전류를 계산하여 차단기를 선정합니다.');
  
  double power = inputDouble('👉 부하 용량(P) [kW]', 15.0);

  print('\n🔄 계산 중 (Real Core Logic)...');

  var params = DesignCurrentParams(
    capacity: power,
    capacityUnit: 'kW',
    systemVoltage: 380,
    wiringType: WiringType.threePhase,
    powerFactor: 0.9,
    isMotorLoad: false, // 일반 부하 가정
  );

  try {
    var result = BreakerCalculator.selectBreaker(
      params: params,
      breakerType: BreakerType.industrial, // 배선용차단기(산업용) 가정
    );

    print('✅ 설계 전류(Ib): ${result.designCurrent.toStringAsFixed(2)} A');
    print('✅ 차단기 선정 기준값(Target): ${result.targetCurrent.toStringAsFixed(2)} A');
    print('✅ 선정된 차단기(In): ${result.selectedBreakerRating} A');
  } catch (e) {
    print('❌ 계산 실패: $e');
  }
}

// ====================================================
//  [4] 단락전류 계산 테스트
// ====================================================
Future<void> _testShortCircuit() async {
  print('\n--- [4] 단락전류 계산 (Short Circuit) - Transformer Method ---');
  print('📝 변압기 정보를 입력받아 간이 계산을 수행합니다.');
  
  double kva = inputDouble('👉 변압기 용량 [kVA]', 1000.0);
  double volt = inputDouble('👉 2차측 전압 [V]', 380.0);
  double imp = inputDouble('👉 퍼센트 임피던스 [%]', 5.0);

  print('\n🔄 계산 중 (Real Core Logic)...');

  try {
    double isCurrent = BreakerCalculator.calculateShortCircuitCurrent(
      kva: kva,
      voltage: volt,
      impedancePercent: imp,
    );
    print('✅ 예상 단락전류(Is): ${isCurrent.toStringAsFixed(2)} kA');
  } catch (e) {
    print('❌ 계산 실패: $e');
  }
}

// ====================================================
//  [5] 접지선 굵기 테스트 (보호도체)
// ====================================================
Future<void> _testEarthing() async {
  print('\n--- [5] 접지선 굵기 (Earthing Size) ---');
  print('📝 단락전류에 견디는 최소 접지선 굵기 계산 (KEC 142.3.2)');
  
  double isCurrent = inputDouble('👉 고장 전류(Is) [kA]', 5.0); 
  double time = inputDouble('👉 차단 동작 시간(t) [sec]', 0.1);

  print('\n🔄 계산 중 (Real Core Logic)...');

  var params = ShortCircuitParams(
    shortCircuitCurrentKa: isCurrent,
    durationSeconds: time,
    insulationType: InsulationType.pvc, // 보통 접지선은 GV(PVC) 사용
  );

  try {
    var result = BreakerCalculator.checkShortCircuitSafety(params: params);
    print('✅ 최소 접지선 굵기: ${result.minCableSizeSq.toStringAsFixed(2)} sq 이상');
    print('ℹ️ (적용 K계수: ${result.kFactor})');
    print('ℹ️ KEC 규격에 맞는 표준 굵기를 선정하세요 (예: 6, 10, 16 sq...)');
  } catch (e) {
    print('❌ 계산 실패: $e');
  }
}

// ====================================================
//  [6] 전선관 굵기 테스트
// ====================================================
Future<void> _testConduit() async {
  print('\n--- [6] 전선관 굵기 (Conduit Size) ---');
  
  double cableArea = inputDouble('👉 전선 굵기(sq)', 4.0);
  double count = inputDouble('👉 전선 가닥수', 3.0);

  print('\n🔄 계산 중 (Real Core Logic)...');

  var params = ConduitParams(
    mainWireSizeSq: cableArea,
    mainWireCount: count.toInt(),
    mainWireType: CableCoreType.single, // 보통 관에는 단심(IV/HFIX) 많이 사용
    earthWireSizeSq: null,
    earthWireCount: 0,
  );

  try {
    var result = ConduitCalculator.calculateDetailed(params);
    
    print('✅ 총 전선 단면적: ${result.totalWireArea.toStringAsFixed(2)} mm²');
    print('✅ 추천 전선관 목록 (여유율 32% 이하 기준):');
    for (var rec in result.recommendations) {
        String safeMark = rec.isSafe ? "O" : "X";
        String warnMsg = "";
        if (rec.disallowedSize != null) {
          warnMsg = " (⚠️ ${rec.disallowedSize}호는 ${rec.disallowedOccupancy?.toStringAsFixed(1)}%로 불가)";
        }
        
        print(' - [${rec.typeLabel}]');
        print('   추천: ${rec.size}호 (여유율 ${rec.occupancyRate.toStringAsFixed(1)}%) [$safeMark]$warnMsg');
    }
    print('\n💡 전문가 팁: ${result.expertTip}');
    
  } catch (e) {
    print('❌ 계산 실패: $e');
  }
}

// ====================================================
//  [7] 통합 설계 테스트
// ====================================================
Future<void> _testIntegration() async {
  print('\n--- [7] 통합 설계 시뮬레이션 (Real Workflow) ---');
  print('📝 시나리오: 3상 380V, 히터 부하, 공사방법 C(기중), XLPE 케이블');
  
  double power = inputDouble('👉 부하 용량 [kW]', 15.0);
  double dist = inputDouble('👉 전선 길이 [m]', 50.0);
  
  print('\n🔄 통합 프로세스 실행...');

  // 1. 차단기 선정
  double designCurrent = 0.0;
  int breakerRating = 0;
  
  try {
      print('\n[Step 1] 부하 전류 및 차단기 선정');
      var breakerParams = DesignCurrentParams(
        capacity: power,
        capacityUnit: 'kW',
        systemVoltage: 380,
        wiringType: WiringType.threePhase,
        powerFactor: 1.0, // 히터
        isMotorLoad: false
      );
      var breakerRes = BreakerCalculator.selectBreaker(
          params: breakerParams, 
          breakerType: BreakerType.industrial
      );
      designCurrent = breakerRes.designCurrent;
      breakerRating = breakerRes.selectedBreakerRating;
      print(' -> 설계전류: ${designCurrent.toStringAsFixed(2)} A');
      print(' -> 선정 차단기: ${breakerRating} A');
  } catch (e) {
      print('FAILED: $e');
      return;
  }

  // 2. 케이블 굵기 선정 (차단기 용량 < 허용전류 만족 필요)
  double selectedCableSize = 0.0;
  try {
    print('\n[Step 2] 케이블 굵기 선정 (허용전류 > $breakerRating A)');
    // 최소 규격 찾기
    var cableParams = CableCapacityParams(
        cableSizeSq: 4.0, // dummy, will be overridden by selectMinCableSize
        insulationType: InsulationType.xlpe,
        conductorType: ConductorType.copper,
        constructionCode: 'C',
        ambientTemperature: 30,
        numberOfCircuits: 1,
        conductorCount: 1,
        parallelConductors: 1
    );
    
    var cableRes = CableCapacityCalculator.selectMinCableSize(
        targetCurrent: breakerRating.toDouble(), 
        params: cableParams
    );
    selectedCableSize = cableRes.cableSizeSq;
    print(' -> 선정된 굵기: $selectedCableSize sq (허용전류 ${cableRes.adjustedIz.toStringAsFixed(2)} A)');

  } catch (e) {
    print('FAILED: $e');
    return;
  }

  // 3. 전압강하 검토
  try {
    // 부하전류 재설정 (위 params에서 loadCurrent는 필수니까)
    var dropParams = VoltageDropParams(
         lengthInMeters: dist,
         cableSizeSq: selectedCableSize,
         loadCurrent: designCurrent, // 정확한 부하전류 사용
         systemVoltage: 380,
         wiringType: WiringType.threePhase,
         powerFactor: 1.0,
         conductorType: ConductorType.copper,
         parallelConductors: 1,
    );

    var dropRes = VoltageDropCalculator.calculate(dropParams);
    print(' -> 전압강하: ${dropRes.dropVoltage.toStringAsFixed(2)} V');
    print(' -> 전압강하율: ${dropRes.dropPercent.toStringAsFixed(2)} %');
    
    if (dropRes.dropPercent > 3.0) {
        print('🚨 [FAIL] 3% 초과! 굵기 증대 필요');
        // 개선 로직(loop)은 생략, 안내만.
    } else {
        print('🟢 [PASS] 적합');
    }
  } catch (e) {
    print('FAILED: $e');
  }

  print('\n✅ 통합 설계 시뮬레이션 완료');
}