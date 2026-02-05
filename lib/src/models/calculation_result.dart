/// 계산 결과를 담는 데이터 클래스
class CalculationResult {
  final double finalCableSize; // 최종 선정된 케이블 굵기 (mm^2)
  final int finalBreakerRating; // 최종 선정된 차단기 용량 (A)
  final List<String> reasoning; // 선정 사유 및 계산 과정 로그
  final double shortCircuitCurrent; // 계산에 사용된 단락 전류 (kA)
  final double shortCircuitDuration; // 계산에 사용된 단락 지속 시간 (s)
  final double minCableSizeForShortCircuit; // 단락전류 고려 최소 굵기 (sq)
  final double kFactor; // 단락전류 계산에 사용된 계수 K
  final Map<String, dynamic> detailResults; // [New] 상세 결과
  final double? reducedShortCircuitCurrent; // [New] 계산된 부하단 단락전류
  final String? dominantReason; // [New] 가장 제한적인 선정 요인
  final double iz; // [New] 허용전류 (A)
  final double ib; // [New] 부하전류 (A)
  final double voltageDropRate; // [New] 전압강하율 (%)

  CalculationResult({
    required this.finalCableSize,
    required this.finalBreakerRating,
    required this.reasoning,
    required this.shortCircuitCurrent,
    required this.shortCircuitDuration,
    required this.minCableSizeForShortCircuit,
    required this.kFactor,
    this.detailResults = const {},
    this.reducedShortCircuitCurrent,
    this.dominantReason,
    this.iz = 0,
    this.ib = 0,
    this.voltageDropRate = 0,
  });
}
