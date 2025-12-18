import '../common/enums.dart';

/// 전압강하 계산을 위한 입력 파라미터
class VoltageDropParams {
  /// 계통 전압 (V)
  final double systemVoltage;

  /// 부하 전류 (A)
  final double loadCurrent;

  /// 선로 길이 (m)
  final double lengthInMeters;

  /// 배선 방식 (단상/3상)
  final WiringType wiringType;

  /// 도체 재질 (구리/알루미늄)
  final ConductorType conductorType;

  /// 역률 (0.0 ~ 1.0)
  final double powerFactor;

  /// 전선 굵기 (mm²)
  final double cableSizeSq;

  /// 병렬 도체 수 (가닥), 기본값 1
  final int parallelConductors;

  /// 저항 (Ohm/km) - 선택 입력 (없으면 스펙 테이블에서 조회 필요)
  final double? resistancePerKm;

  /// 리액턴스 (Ohm/km) - 선택 입력 (없으면 스펙 테이블에서 조회 필요)
  final double? reactancePerKm;

  const VoltageDropParams({
    required this.systemVoltage,
    required this.loadCurrent,
    required this.lengthInMeters,
    required this.wiringType,
    required this.conductorType,
    required this.cableSizeSq,
    this.powerFactor = 1.0,
    this.parallelConductors = 1,
    this.resistancePerKm,
    this.reactancePerKm,
  });
}

/// 전압강하 계산 결과
class VoltageDropResult {
  /// 전압강하 (V)
  final double dropVoltage;

  /// 전압강하율 (%)
  final double dropPercent;

  /// 계산에 사용된 저항 (Ohm/km)
  final double usedResistance;

  /// 계산에 사용된 리액턴스 (Ohm/km)
  final double usedReactance;

  const VoltageDropResult({
    required this.dropVoltage,
    required this.dropPercent,
    required this.usedResistance,
    required this.usedReactance,
  });

  @override
  String toString() {
    return 'VoltageDropResult(drop: ${dropVoltage.toStringAsFixed(2)}V, percent: ${dropPercent.toStringAsFixed(2)}%, R: $usedResistance, X: $usedReactance)';
  }
}
