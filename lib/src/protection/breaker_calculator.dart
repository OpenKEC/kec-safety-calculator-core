import 'dart:math';
import '../common/constants.dart';
import '../common/enums.dart';
import 'protection_models.dart';

/// 차단기 및 보호 장치 계산기
class BreakerCalculator {
  // 기본 상수 (전동기 부하 여유율 기본값)
  static const double _defaultMotorLoadFactor = 1.25;

  /// 설계 전류(Ib) 계산 및 차단기(In) 선정
  static BreakerSelectionResult selectBreaker({
    required DesignCurrentParams params,
    required BreakerType breakerType,
  }) {
    // 1. 설계 전류 (Ib) 계산
    // P = V * I * cosΘ (단상), P = √3 * V * I * cosΘ (3상)
    // I = P / (V * cosΘ) ...

    double powerInWatts = params.capacity;
    // kW input -> convert to W (Assuming input is already raw value? No unit says kW/kVA)
    // Legacy logic: input * 1000
    powerInWatts = params.capacity * 1000.0;

    // kVA인 경우 역률을 1.0으로 간주하고 계산 (P_apparent = P_active / pf 에서 P_active = P_apparent * pf 인데...)
    // Legacy logic: if kVA, powerFactor = 1.0 effectively for the divisor
    double appliedPowerFactor = params.powerFactor;
    if (params.capacityUnit == 'kVA') {
      appliedPowerFactor = 1.0;
      // Note: If input is kVA, then I = P(VA) / V.
      // If we use W formula with PF=1, I = Watts / Voltage. Correct.
    }

    double designCurrent;
    if (params.wiringType == WiringType.threePhase) {
      designCurrent =
          powerInWatts / (sqrt(3) * params.systemVoltage * appliedPowerFactor);
    } else {
      designCurrent =
          powerInWatts / (params.systemVoltage * appliedPowerFactor);
    }

    // 2. 차단기 선정 기준 전류 (Target)
    double targetCurrent = designCurrent;
    if (params.isMotorLoad) {
      final multiplier =
          params.motorStartingMultiplier ?? _defaultMotorLoadFactor;
      targetCurrent = designCurrent * multiplier;
    }

    // 3. 차단기 정격 선정
    // 표준 차단기 목록 조회
    List<int> standardBreakers;
    switch (breakerType) {
      case BreakerType.residential:
        standardBreakers = kResidentialBreakerRatings;
        break;
      case BreakerType.industrial:
        standardBreakers = kIndustrialBreakerRatings;
        break;
      case BreakerType.fuse:
        standardBreakers = kFuseRatings;
        break;
    }

    // Target 이상인 첫 번째 규격 선정
    final int selectedRating = standardBreakers.firstWhere(
        (r) => r >= targetCurrent,
        orElse: () => standardBreakers.last);

    return BreakerSelectionResult(
      designCurrent: designCurrent,
      targetCurrent: targetCurrent,
      selectedBreakerRating: selectedRating,
    );
  }

  /// 단락 전류 시 케이블 최소 굵기 계산 (KEC 234.5)
  /// 공식: S >= (I * √t) / k
  static ShortCircuitResult checkShortCircuitSafety({
    required ShortCircuitParams params,
    double? checkCableSizeSq,
  }) {
    // 1. K 계수 조회
    final double k = kCableMaterialCoefficients[params.insulationType] ?? 143.0;

    // 2. 최소 굵기 계산
    // iSquareT = (I_kA * 1000)^2 * t
    final iSquareT =
        pow(params.shortCircuitCurrentKa * 1000.0, 2) * params.durationSeconds;
    final minSize = sqrt(iSquareT) / k;

    bool? isSafe;
    if (checkCableSizeSq != null) {
      isSafe = checkCableSizeSq >= minSize;
    }

    return ShortCircuitResult(
      minCableSizeSq: minSize,
      kFactor: k,
      isSafe: isSafe,
    );
  }

  /// 변압기 기준 단락전류 계산 (간이식)
  ///
  /// [kva]: 변압기 용량 (kVA)
  /// [voltage]: 전압 (V)
  /// [impedancePercent]: 퍼센트 임피던스 (%Z)
  ///
  /// 반환값: 단락전류 (kA)
  static double calculateShortCircuitCurrent({
    required double kva,
    required double voltage,
    required double impedancePercent,
  }) {
    if (impedancePercent <= 0) return 0.0;

    // 정격 전류 In = P / (√3 * V)
    final double inCurrent = (kva * 1000) / (sqrt(3) * voltage);

    // 단락 전류 Is = (100 / %Z) * In
    final double isCurrent = (100 / impedancePercent) * inCurrent;

    // kA 단위로 반환
    return isCurrent / 1000.0;
  }
}
