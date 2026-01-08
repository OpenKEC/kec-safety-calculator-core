/// 분전반 증설 용량 검토 결과
class PanelCapacityResult {
  /// 종합 안전 여부
  final bool isSafe;

  /// 시스템 설계 안전성 (1차측 차단기 vs 케이블)
  final bool isHardwareSafe;

  /// 1차측 케이블 과부하 여부
  final bool isCableSafe;

  /// 메인 차단기 과부하 여부
  final bool isBreakerSafe;

  /// 증설 후 총 부하 전류 (A)
  final double totalLoadCurrent;

  /// 여유 용량 (A) (메인차단기 - 총부하)
  final double marginCurrent;

  /// 안전율 기반 경고 상태 (ex: 80% 초과 시 warning)
  final bool isWarning;

  /// 결과 메시지
  final String resultMessage;

  const PanelCapacityResult({
    required this.isSafe,
    required this.isHardwareSafe,
    required this.isCableSafe,
    required this.isBreakerSafe,
    required this.totalLoadCurrent,
    required this.marginCurrent,
    this.isWarning = false,
    required this.resultMessage,
  });
}

/// 분기 회로 적합성 검토 결과
class BranchCapacityResult {
  /// 분기 차단기 적합 여부 (부하전류 < 차단기)
  final bool isBreakerSafe;

  /// 분기 케이블 적합 여부 (차단기 < 케이블 허용전류)
  final bool isCableSafe;

  /// 요구되는 최소 분기 차단기 용량 (A)
  final double requiredBreakerCapacity;

  const BranchCapacityResult({
    required this.isBreakerSafe,
    required this.isCableSafe,
    required this.requiredBreakerCapacity,
  });

  bool get isSafe => isBreakerSafe && isCableSafe;
}

/// 부하 종류
enum LoadType {
  resistive, // PF 1.0
  motor, // PF 0.8
}

/// 분전반 부하 증설 검토 계산기
class PanelCalculator {
  /// 분전반 전체 용량 검토
  static PanelCapacityResult checkPanelSafety({
    required double mainBreakerRating, // 메인 차단기 정격 (A)
    required double cableAmpacity, // 1차측 케이블 허용전류 (A)
    required double existingLoadCurrent, // 기존 부하 (A)
    required double newLoadCurrent, // 증설 부하 (A)
    double safetyMarginPercent = 80.0, // 안전율 (기본 80%)
  }) {
    final totalLoad = existingLoadCurrent + newLoadCurrent;

    // 1. 하드웨어 매칭 검사 (차단기가 케이블보다 크면 위험)
    final bool isHardwareSafe = mainBreakerRating <= cableAmpacity;

    // 2. 케이블 과부하 검사
    final bool isCableSafe = totalLoad <= cableAmpacity;

    // 3. 차단기 과부하 검사
    final bool isBreakerSafe = totalLoad <= mainBreakerRating;

    // 종합 안전 여부
    final bool isSafe = isHardwareSafe && isCableSafe && isBreakerSafe;

    // 안전율 경고 (위험하지 않지만 여유율 부족)
    final double safeLimit = mainBreakerRating * (safetyMarginPercent / 100.0);
    final bool isWarning = isSafe && (totalLoad > safeLimit);

    final margin = mainBreakerRating - totalLoad;
    String message;

    if (!isHardwareSafe) {
      message =
          'Hardware Mismatch: Breaker ($mainBreakerRating A) > Cable ($cableAmpacity A)';
    } else if (!isSafe) {
      message = 'Overload: Total ($totalLoad A) exceeds capacity';
    } else if (isWarning) {
      message = 'Warning: Load exceeds $safetyMarginPercent% safety margin';
    } else {
      message = 'Safe: Margin ${margin.toStringAsFixed(1)} A';
    }

    return PanelCapacityResult(
      isSafe: isSafe,
      isHardwareSafe: isHardwareSafe,
      isCableSafe: isCableSafe,
      isBreakerSafe: isBreakerSafe,
      totalLoadCurrent: totalLoad,
      marginCurrent: margin,
      isWarning: isWarning,
      resultMessage: message,
    );
  }

  /// 증설 분기 회로 적합성 검토
  static BranchCapacityResult checkBranchSafety({
    required double newLoadCurrent, // 증설 부하 전류 (A)
    required LoadType loadType, // 부하 종류
    required int branchBreakerRating, // 선택된 분기 차단기 (AT)
    required int branchCableAmpacity, // 선택된 분기 케이블 허용전류 (A)
  }) {
    // 1. 분기 차단기 적정성 검토
    // 일반 부하: 1.1배, 모터 부하: 1.25배 여유율 적용
    final double factor = (loadType == LoadType.motor) ? 1.25 : 1.1;
    final double requiredBreaker = newLoadCurrent * factor;
    final bool isBreakerSafe = branchBreakerRating >= requiredBreaker;

    // 2. 분기 케이블 적정성 검토
    // 차단기 용량보다 케이블 허용전류가 커야 함 (차단기가 보호할 수 있어야 함)
    final bool isCableSafe = branchCableAmpacity >= branchBreakerRating;

    return BranchCapacityResult(
      isBreakerSafe: isBreakerSafe,
      isCableSafe: isCableSafe,
      requiredBreakerCapacity: requiredBreaker,
    );
  }
}
