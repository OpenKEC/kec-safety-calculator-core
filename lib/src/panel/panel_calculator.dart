/// 분전반 증설 용량 검토 결과
class PanelCapacityResult {
  /// 설치 가능 여부
  final bool isSafe;

  /// 증설 후 총 부하 전류 (A)
  final double totalLoadCurrent;

  /// 여유 용량 (A) (메인차단기 - 총부하)
  /// 부족할 경우 음수
  final double marginCurrent;

  /// 결과 메시지 (UI용 아님, 로직 처리 결과 설명)
  final String resultMessage;

  const PanelCapacityResult({
    required this.isSafe,
    required this.totalLoadCurrent,
    required this.marginCurrent,
    required this.resultMessage,
  });
}

/// 분전반 부하 증설 검토 계산기
class PanelCalculator {
  /// 증설 가능 여부 확인
  static PanelCapacityResult checkCapacity({
    required double mainBreakerRating, // 메인 차단기 정격 (A)
    required double existingLoadCurrent, // 기존 부하 전류 (A)
    required double newLoadCurrent, // 추가될 부하 전류 (A)
  }) {
    final totalLoad = existingLoadCurrent + newLoadCurrent;
    final isSafe = mainBreakerRating >= totalLoad;
    final margin = mainBreakerRating - totalLoad;

    // 메시지 생성 (UI 독립적이지만 기본적인 상태 설명 포함)
    String message;
    if (isSafe) {
      message = 'Safe: Margin ${margin.toStringAsFixed(1)}A';
    } else {
      message = 'Unsafe: Overload ${margin.abs().toStringAsFixed(1)}A';
    }

    return PanelCapacityResult(
      isSafe: isSafe,
      totalLoadCurrent: totalLoad,
      marginCurrent: margin,
      resultMessage: message,
    );
  }
}
