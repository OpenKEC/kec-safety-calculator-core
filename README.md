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

이 라이브러리는 다음과 같은 핵심 전기 계산 모듈을 제공합니다:

1. **전선 허용전류 (Allowable Current)**
    * 부하 용량 기준 케이블 선정
    * KEC/IEC 규격에 따른 공사 방법(A1, B1, C, D 등) 및 보정계수 자동 적용
2. **전선 굵기 선정 (Cable Size Selection)**
    * 차단기/단락/접지 통합 계산
    * 설계 전류 ≤ 차단기 정격 ≤ 케이블 허용전류 ($I_B \le I_n \le I_z$) 검증 로직
3. **전압강하 계산 (Voltage Drop)**
    * 선로 길이와 허용 강하율 고려
    * 단상/3상 회로 및 역률을 고려한 정밀 계산
4. **단락전류 계산 (Short-circuit Current)**
    * 변압기 용량 기준 고장 전류 산출
    * 임피던스 맵 기반의 단락 전류 계산 (보호장치 정격 차단 용량 검토)
5. **접지선 굵기 (Earthing Conductor)**
    * KEC 142.3.2 보호도체 선정
    * 단락 전류와 차단 시간을 고려한 최소 단면적 계산 (절연/나도체 구분)
6. **전선관 굵기 (Conduit Sizing)**
    * 가닥수 기반 전선관 규격 선정
    * 절연 전선의 단면적 합계와 전선관 내 단면적 비율(32% / 48%) 검토
7. **분전반 증설 (Panel Expansion)**
    * 부하 증설 및 용량 안전성 검토
    * 기존 부하와 증설 부하의 합계를 통한 메인 차단기 및 간선 규격 적정성 판별

  
## 📦 설치 방법 (Installation)

이 프로젝트는 현재 개발 초기 단계이므로, Git URL을 통해 의존성을 추가할 수 있습니다. `pubspec.yaml` 파일에 아래 내용을 추가하십시오.

```yaml
dependencies:
  kec_safety_calculator_core:
    git:
      url: https://github.com/OpenKEC/kec-safety-calculator-core.git
      ref: main
```

  
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
```

  
## 🤝 기여하기 (Contributing)

**OpenKEC**는 현업 전기 기술자와 개발자 모두의 참여를 기다립니다.  
KEC 규정의 해석, 수식 오류 수정, 새로운 계산 모듈 제안 등 어떤 형태의 기여도 환영합니다.

1. 이 저장소를 **Fork** 합니다.
2. 새로운 기능 브랜치를 생성합니다 (`git checkout -b feature/NewFeature`).
3. 변경 사항을 **Commit** 합니다 (`git commit -m 'Add some NewFeature'`).
4. 브랜치에 **Push** 합니다 (`git push origin feature/NewFeature`).
5. GitHub에서 **Pull Request**를 생성합니다.

  
## 📄 라이선스 (License)

이 프로젝트는 **MIT License** 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참고하십시오.

**면책 조항 (Disclaimer):**
이 소프트웨어의 계산 결과는 설계 참고용입니다.   
최종 전기 설계 및 시공에 대한 법적 책임은 사용자(엔지니어)에게 있으며, 제공자는 이에 대한 책임을 지지 않습니다.

---
Copyright © 2025 **OpenKEC Lab**. Developed by **LeeTech**.
