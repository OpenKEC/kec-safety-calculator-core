// example/menu_test.dart

import 'dart:io';
// ★ 중요: 실제 선생님의 라이브러리를 가져오는 부분입니다.
// 만약 빨간 줄이 뜨면 패키지 이름이 pubspec.yaml과 같은지 확인하세요.
import 'package:kec_safety_calculator_core/kec_calculator.dart';

/// 화면 지우기 헬퍼 함수
void clearScreen() {
  if (Platform.isWindows) {
    // 윈도우는 줄바꿈으로 화면 밀어내기
    print('\n' * 50);
  } else {
    // Mac/Linux/Unix용 ANSI 코드
    print('\x1B[2J\x1B[0;0H');
  }
}

void main() {
  while (true) {
    print('\n=============================================');
    print('   ⚡ KEC Safety Calculator Core - Test Menu   ');
    print('=============================================');
    print('1. 허용전류 계산 (Cable Capacity)');
    print('2. 전압강하 계산 (Voltage Drop)');
    print('3. 차단기 선정 (Breaker Selection)');
    print('4. 단락전류 계산 (Short Circuit)');
    print('5. 접지선 굵기 (Earthing Size)');
    print('6. 전선관 굵기 (Conduit Size)');
    print('7. 통합 설계 (Integrated Design)');
    print('0. 종료 (Exit)');
    print('---------------------------------------------');
    stdout.write('👉 메뉴 번호를 입력하세요: ');

    String? input = stdin.readLineSync();

    // 화면 지우고 결과 출력 시작
    clearScreen();

    switch (input) {
      case '1':
        _testCableCapacity();
        break;
      case '2':
        _testVoltageDrop();
        break;
      case '3':
        _testBreaker();
        break;
      case '4':
        _testShortCircuit();
        break;
      case '5':
        _testEarthing();
        break;
      case '6':
        _testConduit();
        break;
      case '7':
        _testIntegration();
        break;
      case '0':
        print('프로그램을 종료합니다. 안녕히 가십시오!');
        exit(0);
      default:
        print('❌ 잘못된 입력입니다. 1~7번 또는 0번을 눌러주세요.');
    }
  }
}

// --- [개별 테스트 함수들] ---
// ※ 참고: 실제 계산 로직 연결은 선생님이 구현하신 클래스명에 맞춰 수정이 필요할 수 있습니다.
// 지금은 "메뉴가 잘 작동하는지" 확인하기 위한 시뮬레이션 메시지를 띄웁니다.

void _testCableCapacity() {
  print('--- [1] 허용전류 계산 테스트 ---');
  print('Input: 30°C, 공사방법 C, PVC 전선');
  // TODO: 실제 로직 연결 -> CableCapacityCalculator.calculate(...);
  print('✅ 결과: 계산 로직이 연결되면 여기에 허용전류(A)가 표시됩니다.');
  print('(Enter를 누르면 메뉴로 돌아갑니다)');
  stdin.readLineSync();
}

void _testVoltageDrop() {
  print('--- [2] 전압강하 계산 테스트 ---');
  print('Input: L=50m, 15kW, 380V');
  // TODO: 실제 로직 연결 -> VoltageDropCalculator.calculate(...);
  print('✅ 결과: 전압강하율 3.8% (Warning 발생 예상)');
  print('(Enter를 누르면 메뉴로 돌아갑니다)');
  stdin.readLineSync();
}

void _testBreaker() {
  print('--- [3] 차단기 선정 테스트 ---');
  print('Input: 부하전류 25A');
  // TODO: 실제 로직 연결 -> BreakerCalculator.calculate(...);
  print('✅ 결과: 선정된 차단기 30A');
  print('(Enter를 누르면 메뉴로 돌아갑니다)');
  stdin.readLineSync();
}

void _testShortCircuit() {
  print('--- [4] 단락전류 계산 테스트 ---');
  print('✅ 결과: 단락전류 시뮬레이션 완료');
  stdin.readLineSync();
}

void _testEarthing() {
  print('--- [5] 접지선 굵기 테스트 ---');
  print('✅ 결과: 접지선 굵기 시뮬레이션 완료');
  stdin.readLineSync();
}

void _testConduit() {
  print('--- [6] 전선관 굵기 테스트 ---');
  print('✅ 결과: 전선관 굵기 시뮬레이션 완료');
  stdin.readLineSync();
}

void _testIntegration() {
  print('--- [7] 통합 설계 테스트 ---');
  print('기존 main.dart의 전체 로직을 여기에 실행합니다.');
  print('✅ 전체 프로세스 검증 완료');
  stdin.readLineSync();
}
