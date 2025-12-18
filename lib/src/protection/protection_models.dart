import '../common/enums.dart';

/// 부하 정보 및 차단기 선정 파라미터
class DesignCurrentParams {
  /// 용량 값 (예: 10kW -> 10, 100kVA -> 100)
  final double capacity;

  /// 용량 단위 ('kW' or 'kVA')
  final String capacityUnit;

  /// 전압 (V)
  final double systemVoltage;

  /// 배선 방식 (단상/3상)
  final WiringType wiringType;

  /// 역률 (0.0 ~ 1.0)
  final double powerFactor;

  /// 전동기 부하 여부 (여유율 적용 위함)
  final bool isMotorLoad;

  /// 전동기 기동 배수 (입력 없으면 기본값 적용)
  final double? motorStartingMultiplier;

  const DesignCurrentParams({
    required this.capacity,
    required this.capacityUnit,
    required this.systemVoltage,
    required this.wiringType,
    this.powerFactor = 1.0,
    this.isMotorLoad = false,
    this.motorStartingMultiplier,
  });
}

/// 단락 전류 계산 파라미터 (단락 시 케이블 최소 굵기 산정용)
class ShortCircuitParams {
  /// 단락 전류 (kA)
  final double shortCircuitCurrentKa;

  /// 단락 지속 시간 (초)
  final double durationSeconds;

  /// 절연체 종류 (PVC/XLPE) - K계수 산정용
  final InsulationType insulationType;

  const ShortCircuitParams({
    required this.shortCircuitCurrentKa,
    required this.durationSeconds,
    required this.insulationType,
  });
}

/// 차단기 선정 결과
class BreakerSelectionResult {
  /// 설계 전류 (Ib) - 부하 전류
  final double designCurrent;

  /// 차단기 선정 기준 전류 (전동기 여유율 등 적용된 타겟 전류)
  final double targetCurrent;

  /// 선정된 차단기 정격 전류 (In) (A)
  final int selectedBreakerRating;

  const BreakerSelectionResult({
    required this.designCurrent,
    required this.targetCurrent,
    required this.selectedBreakerRating,
  });
}

/// 단락 안전성 검토 결과
class ShortCircuitResult {
  /// 계산된 최소 안전 굵기 (mm²)
  final double minCableSizeSq;

  /// 적용된 K계수
  final double kFactor;

  /// 안전 여부 (검토하려는 케이블 굵기를 입력받은 경우)
  final bool? isSafe;

  const ShortCircuitResult({
    required this.minCableSizeSq,
    required this.kFactor,
    this.isSafe,
  });
}
