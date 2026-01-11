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
    double powerInWatts = params.capacity * 1000.0;
    double appliedPowerFactor = params.powerFactor;
    if (params.capacityUnit == 'kVA') {
      appliedPowerFactor = 1.0;
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
  static ShortCircuitResult checkShortCircuitSafety({
    required ShortCircuitParams params,
    double? checkCableSizeSq,
  }) {
    final double k = kCableMaterialCoefficients[params.insulationType] ?? 143.0;

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
  static double calculateShortCircuitCurrent({
    required double kva,
    required double voltage,
    required double impedancePercent,
  }) {
    if (impedancePercent <= 0) return 0.0;
    final double inCurrent = (kva * 1000) / (sqrt(3) * voltage);
    final double isCurrent = (100 / impedancePercent) * inCurrent;
    return isCurrent / 1000.0;
  }

  /// [New Feature] 선로 임피던스를 고려한 말단 단락전류 감소 계산
  /// 
  /// [startKA]: 시작점 단락전류 (kA)
  /// [length]: 선로 길이 (m)
  /// [sq]: 케이블 굵기 (mm²)
  static double calculateReducedShortCircuitCurrent({
    required double startKA,
    required double length,
    required double sq,
  }) {
    // 임피던스 데이터(IEC) 조회
    if (!kIecCableImpedanceData.containsKey(sq)) return startKA;
    
    double r = kIecCableImpedanceData[sq]![0];
    double x = kIecCableImpedanceData[sq]![1];
    
    // 단순화된 계산을 위해 상전압 기준 (220V)
    double voltagePhase = 220.0;
    
    double startAmps = startKA * 1000;
    if (startAmps == 0) return 0.0;
    
    // Z_source (전원측 임피던스)
    double zSource = voltagePhase / startAmps;
    
    // Z_line (선로 임피던스: 단방향 or 왕복? KEC 핸드북은 왕복 고려하기도 함. 여기서는 편도 기준 R,X * Line으로 근사)
    // Note: ver1.1.1 로직은 length/1000 * r 입니다.
    double rLine = r * (length / 1000);
    double xLine = x * (length / 1000);
    
    // 전체 임피던스 합성
    // Z_total = sqrt( (R_line)^2 + (X_source + X_line)^2 )  (R_source는 무시 또는 Z_source를 X로 간주)
    // 일반적인 간이 계산: Z_source는 리액턴스 성분이 지배적이라 가정.
    double xTotal = zSource + xLine;
    double rTotal = rLine;
    
    double zTotal = sqrt((rTotal * rTotal) + (xTotal * xTotal));
    
    if (zTotal == 0) return startKA;

    return (voltagePhase / zTotal) / 1000.0; // kA
  }
}
