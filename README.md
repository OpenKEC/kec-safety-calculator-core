# KEC Safety Calculator Core

![License](https://img.shields.io/badge/license-MIT-blue.svg) 
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart) 
![Version](https://img.shields.io/badge/Version-1.2.0-brightgreen)

> **Korea Electro-technical Code (KEC) Safety Verification Engine**  
> 한국전기설비규정(KEC)에 기반한 전기 안전 검토 및 설계 자동화를 위한 **핵심 계산 라이브러리**입니다.

---

## 📖 프로젝트 소개 (Introduction)

**KEC Safety Calculator Core**는 전기 설계 및 시공 실무에서 필수적인 전기 안전 계산 수식을 **Pure Dart** 언어로 구현한 모듈입니다.  
Flutter 프레임워크에 대한 의존성 없이 독립적으로 실행 가능하여, 모바일 앱뿐만 아니라 웹 서버, 데스크톱 애플리케이션 등 다양한 환경에서 재사용할 수 있습니다.

### 특징 (Highlights)
- **Pure Dart**: Flutter 등 UI 프레임워크에 종속되지 않는 순수 비즈니스 로직.
- **Clean Architecture**: UseCase, Repository, Model로 명확히 분리된 구조.
- **Proven Logic**: 실무 앱(`kec_calculator` v1.2.0)에서 검증된 최신 KEC 계산 로직 탑재.

---

## ⚡ 주요 기능 (Key Features)

이 라이브러리는 다음과 같은 핵심 계산 UseCase를 제공합니다:

* **전압강하 계산 (Voltage Drop)**
    * `CalculateVoltageDropUseCase`
    * 단상/3상 회로 및 전동기 기동 시 전압강하 검토
* **케이블 허용전류 산정 (Ampacity)**
    * `CalculateAmpacityUseCase`
    * 공사 방법(A1, B, C, D 등), 온도 보정, 집합 보정 자동 적용
* **차단기 및 케이블 굵기 선정 (Sizing)**
    * `CalculateCableSizeUseCase`
    * 설계 전류와 과부하 보호 장치 정격을 고려한 최적 규격 선정
* **단락전류 계산 (Short-circuit Current)**
    * `CalculateShortCircuitUseCase`
    * 임피던스법을 이용한 부하 말단 고장 전류 추정 및 열적 내력 검토
* **전선관 굵기 선정 (Conduit Sizing)**
    * `CalculateConduitUseCase`
    * 전선 단면적 총합과 전선관 내단면적 비교(32% 룰 등)

---

## 📦 설치 방법 (Installation)

`pubspec.yaml` 파일에 아래 내용을 추가하십시오.

```yaml
dependencies:
  kec_safety_calculator_core:
    git:
      url: https://github.com/OpenKEC/kec-safety-calculator-core.git
      ref: main
```

---

## 🚀 사용 예시 (Usage)

다음은 **전압강하**를 계산하는 예시 코드입니다.

```dart
import 'package:kec_safety_calculator_core/kec_safety_calculator_core.dart';

void main() {
  // UseCase 인스턴스 생성 (일반적으로 DI 사용 권장)
  final repository = CableRepositoryImpl(); 
  final service = KecCalculatorService(repository);
  final useCase = CalculateVoltageDropUseCase(service); // 혹은 서비스 직접 사용

  // ... (로직 구현)
}
```

> **참고:** 이 패키지는 `KecCalculatorService`를 통해 대부분의 계산 로직을 캡슐화하고 있습니다. 
> 상세한 사용법은 `test/` 또는 `src/usecases/` 내부 코드를 참조하십시오.

---

## 🤝 기여하기 (Contributing)

1. 이 저장소를 **Fork** 합니다.
2. 새로운 기능 브랜치를 생성합니다 (`git checkout -b feature/NewFeature`).
3. 변경 사항을 **Commit** 합니다 (`git commit -m 'Add some NewFeature'`).
4. 브랜치에 **Push** 합니다 (`git push origin feature/NewFeature`).
5. GitHub에서 **Pull Request**를 생성합니다.

---

## 📄 라이선스 (License)

이 프로젝트는 **MIT License** 하에 배포됩니다. 

**면책 조항 (Disclaimer):**
이 소프트웨어의 계산 결과는 설계 참고용입니다. 최종 전기 설계 및 시공에 대한 법적 책임은 사용자(엔지니어)에게 있으며, 개발자는 이에 대한 책임을 지지 않습니다.

---
Copyright © 2026 **OpenKEC Lab**.
