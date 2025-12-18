# KEC Safety Calculator Core

![License](https://img.shields.io/badge/license-MIT-blue.svg) 
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart) 
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

> **Korea Electro-technical Code (KEC) Safety Verification Engine** > 한국전기설비규정(KEC)에 기반한 전기 안전 검토 및 설계 자동화를 위한 핵심 계산 라이브러리입니다.

---

## 📖 프로젝트 소개 (Introduction)

**KEC Safety Calculator Core**는 전기 설계 및 시공 실무에서 필수적인 전기 안전 계산 수식을 **Dart** 언어로 구현한 오픈소스 프로젝트입니다.

복잡한 KEC 규정(IEC 60364 부합)을 표준화된 코드로 제공하여, 엔지니어들이 엑셀이나 수기로 계산하던 방식을 넘어 **소프트웨어 기반의 자동화된 검증**을 수행할 수 있도록 돕습니다. 이 저장소는 UI가 포함되지 않은 **순수 계산 로직(Pure Logic)** 라이브러리로, 모바일 앱(Flutter)이나 웹 서비스의 백엔드 엔진으로 활용하기에 최적화되어 있습니다.

## ⚡ 주요 기능 (Key Features)

이 라이브러리는 다음과 같은 핵심 전기 계산 모듈을 포함합니다 (예정 포함):

* **전압강하 계산 (Voltage Drop)**
    * 단상(1Φ2W, 1Φ3W) 및 3상(3Φ3W, 3Φ4W) 회로 계산
    * 선로 길이 및 역률(Power Factor)을 고려한 전압강하율 산정
* **케이블 허용전류 산정 (Allowable Current)**
    * KEC/IEC 규격에 따른 공사 방법(A1, B1, C, D 등) 적용
    * 주위 온도 및 토양 열저항에 따른 보정계수 자동 적용
    * 복수 회로 포설 시 저감계수 적용
* **차단기 용량 선정 (Circuit Breaker Sizing)**
    * 설계 전류($I_B$) ≤ 차단기 정격($I_n$) ≤ 케이블 허용전류($I_z$) 검증 로직
    * 과부하 보호 및 단락 보호 협조 검토
* **고장 전류 계산 (Short-circuit Current)**
    * 임피던스 맵(Impedance Map) 기반의 단락 전류 계산 (향후 업데이트)

## 📦 설치 방법 (Installation)

이 프로젝트는 현재 개발 초기 단계이므로, Git URL을 통해 의존성을 추가할 수 있습니다. `pubspec.yaml` 파일에 아래 내용을 추가하십시오.

```yaml
dependencies:
  kec_safety_calculator_core:
    git:
      url: [https://github.com/OpenKEC/kec-safety-calculator-core.git](https://github.com/OpenKEC/kec-safety-calculator-core.git)
      ref: main

```markdown
## 🚀 사용 예시 (Usage)

다음은 전압강하를 계산하는 간단한 코드 예시입니다. 설명대로 값을 넣으면 결과를 바로 확인할 수 있습니다.

```dart
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  // 1. 계산 조건 설정
  // 예: 3상 4선식 380V, 부하전류 50A, 거리 100m, 케이블 35sq
  var params = VoltageDropParams(
    voltageSystem: VoltageSystem.threePhase4Wire, 
    voltage: 380.0,
    current: 50.0,
    length: 100.0,
    cableCSA: 35.0, // Cross Sectional Area (sq)
    powerFactor: 0.9,
  );

  // 2. 계산 수행
  var result = VoltageDropCalculator.calculate(params);

  // 3. 결과 출력
  print('전압강하(V): ${result.dropVoltage.toStringAsFixed(2)} V');
  print('전압강하율(%): ${result.dropRate.toStringAsFixed(2)} %');
  
  // 4. KEC 규정 적합 여부 판단 (예: 5% 이내)
  if (result.dropRate <= 5.0) {
    print('✅ 적합: 전압강하가 허용 범위 이내입니다.');
  } else {
    print('❌ 부적합: 케이블 굵기를 선정해 주십시오.');
  }
}
