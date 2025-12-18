import 'dart:io';
// ★ 패키지 이름이 다르면 pubspec.yaml에 있는 이름으로 수정하세요.
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
    print('   ⚡ KEC Safety Calculator Core - 통합 테스트   ');
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
  print('📝 조건: TFR-CV, 3상, 공사방법 C(기중) 가정');

  // 사용자 입력
  double size = inputDouble('👉 전선 굵기(sq) 입력', 4.0);
  double temp = inputDouble('👉 주위 온도(°C) 입력', 30.0);

  print('\n🔄 계산 중...');

  // [TODO] 실제 선생님의 CableCapacityCalculator 연결
  // 예시 코드 (실제 클래스명으로 수정 필요):
  /*
  var params = CableCapacityParams(
     conductorSize: size,
     temperature: temp,
     insulation: InsulationType.xlpe, 
     method: InstallationMethod.c
  );
  var result = CableCapacityCalculator.calculate(params);
  print('✅ 계산된 허용전류: $result A');
  */

  // (임시 시뮬레이션 로직)
  double simulResult = (size < 6) ? 34.0 : 50.0; 
  if (temp > 30) simulResult *= 0.9; // 온도 보정 흉내
  print('✅ (시뮬레이션) 허용전류: ${simulResult.toStringAsFixed(2)} A');
}

// ====================================================
//  [2] 전압강하 계산 테스트
// ====================================================
Future<void> _testVoltageDrop() async {
  print('\n--- [2] 전압강하 계산 (Voltage Drop) ---');
  
  double dist = inputDouble('👉 전선 길이(L) [m]', 50.0);
  double current = inputDouble('👉 부하 전류(I) [A]', 25.0);
  double size = inputDouble('👉 전선 굵기(A) [sq]', 4.0);

  print('\n🔄 계산 중...');

  // [TODO] 실제 선생님의 VoltageDropCalculator 연결
  /*
  var params = VoltageDropParams(
    length: dist,
    current: current,
    area: size,
    voltage: 380,
    isThreePhase: true
  );
  var result = VoltageDropCalculator.calculate(params);
  print('✅ 전압강하: ${result.dropVoltage} V (${result.dropPercent}%)');
  */

  // (임시 약식 계산 식)
  double e = (30.8 * dist * current) / (1000 * size);
  double rate = (e / 380) * 100;
  
  print('✅ (시뮬레이션) 전압강하: ${e.toStringAsFixed(2)} V');
  print('✅ (시뮬레이션) 전압강하율: ${rate.toStringAsFixed(2)} %');
  if (rate > 3.0) print('⚠️ [경고] 허용 기준 3% 초과!');
}

// ====================================================
//  [3] 차단기 선정 테스트
// ====================================================
Future<void> _testBreaker() async {
  print('\n--- [3] 차단기 선정 (Breaker Selection) ---');
  
  double ib = inputDouble('👉 설계 전류(Ib) [A]', 22.0);

  print('\n🔄 계산 중...');

  // [TODO] BreakerCalculator 연결
  /*
  double breaker = BreakerCalculator.selectBreaker(ib);
  print('✅ 선정된 차단기: $breaker A');
  */
  
  // (임시 로직)
  int selected = 0;
  List<int> standard = [15, 20, 30, 40, 50, 60, 75, 100];
  for (var b in standard) {
    if (b > ib) {
      selected = b;
      break;
    }
  }
  print('✅ (시뮬레이션) 선정된 차단기: ${selected} A');
}

// ====================================================
//  [4] 단락전류 계산 테스트
// ====================================================
Future<void> _testShortCircuit() async {
  print('\n--- [4] 단락전류 계산 (Short Circuit) ---');
  double impedance = inputDouble('👉 임피던스(Z) [ohm]', 0.05);
  double volt = inputDouble('👉 전압(V)', 220.0);

  // Is = V / Z
  double result = volt / impedance;
  print('✅ (시뮬레이션) 예상 단락전류: ${(result/1000).toStringAsFixed(2)} kA');
}

// ====================================================
//  [5] 접지선 굵기 테스트
// ====================================================
Future<void> _testEarthing() async {
  print('\n--- [5] 접지선 굵기 (Earthing Size) ---');
  
  double isCurrent = inputDouble('👉 고장 전류(Is) [kA]', 5.0); // kA 단위
  double time = inputDouble('👉 동작 시간(t) [sec]', 0.1);

  // KEC 142.3.2 (S = sqrt(I^2 * t) / k)
  // 구리선 k=143 가정
  double s = (isCurrent * 1000 * 1000 * time) / 143; // 제곱근 전 단순화
  // 실제 공식: S = (I * sqrt(t)) / k
  // I는 Ampere 단위
  double result = (isCurrent * 1000 * (time > 0 ?  (time * 0.5) : 0.1)) / 143; // 단순 근사치
  
  print('✅ (시뮬레이션) 최소 접지선 굵기: 6 sq 이상 권장 (계산값: ${result.toStringAsFixed(2)})');
}

// ====================================================
//  [6] 전선관 굵기 테스트
// ====================================================
Future<void> _testConduit() async {
  print('\n--- [6] 전선관 굵기 (Conduit Size) ---');
  
  double cableArea = inputDouble('👉 전선 단면적(sq)', 4.0);
  double count = inputDouble('👉 전선 가닥수', 3.0);

  // 내선규정: 관 내 단면적의 32% (또는 48%) 이하
  print('✅ (시뮬레이션) 추천 전선관: 16 mm (후강전선관 기준)');
}

// ====================================================
//  [7] 통합 설계 테스트
// ====================================================
Future<void> _testIntegration() async {
  print('\n--- [7] 통합 설계 시뮬레이션 (All-in-One) ---');
  print('📝 시나리오: 15kW 히터 (3상 380V), 거리 50m');
  
  double power = 15.0; // kW
  double dist = 50.0;  // m
  
  // 1. 전류 계산 (I = P / (sqrt(3)*V*cosT))
  double current = (power * 1000) / (1.732 * 380 * 1.0);
  print('\n[Step 1] 부하 전류 계산: ${current.toStringAsFixed(2)} A');

  // 2. 차단기 선정
  print('[Step 2] 차단기 선정: 30 A (25.3A < 30A)');

  // 3. 케이블 선정 (허용전류 > 30A)
  print('[Step 3] 케이블 선정: 4 sq (허용전류 34A > 차단기 30A)');

  // 4. 전압강하 검토
  double e = (30.8 * dist * 30) / (1000 * 4); // 전류는 차단기 용량 기준 보수적 계산
  double rate = (e / 380) * 100;
  print('[Step 4] 전압강하 검토: ${rate.toStringAsFixed(2)} %');
  
  if (rate > 3.0) {
    print('🚨 [FAIL] 전압강하 3% 초과! -> 전선 굵기 상향 필요 (4sq -> 6sq)');
  } else {
    print('🟢 [PASS] 설계 적합');
  }
}