/// 접지 도체 굵기 계산기
class EarthingCalculator {
  /// 접지 도체 최소 굵기 선정 (KEC 142.3.2 단순화)
  ///
  /// [s] = 상도체(Line Conductor)의 단면적 (mm²)
  static double calculateMinSize(double s) {
    if (s <= 16) return s;
    if (s <= 35) return 16;
    return s / 2;
  }
}
