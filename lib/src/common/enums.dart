/// 배선 방식 (Wiring Method)
enum WiringType {
  singlePhase, // 단상
  threePhase, // 3상
}

/// 도체 재질 (Conductor Material)
enum ConductorType {
  copper, // 구리
  aluminum, // 알루미늄
}

/// 절연체 종류 (Insulation Type)
enum InsulationType {
  pvc, // PVC
  xlpe, // XLPE (or EPR)
}

/// 차단기 종류 (Breaker Type)
enum BreakerType {
  residential, // 주택용 (MCB)
  industrial, // 산업용 (MCCB)
  fuse, // 퓨즈
}

/// 설치 장소 (Installation Environment)
enum InstallationType {
  air, // 기중
  ground, // 지중
}

/// 케이블 코어 타입 (Cable Core Type)
enum CableCoreType {
  single, // 단심
  multi, // 다심
}
