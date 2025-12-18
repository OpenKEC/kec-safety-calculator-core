import '../common/enums.dart';

/// 케이블 허용전류 계산 파라미터
class CableCapacityParams {
  /// 전선 굵기 (mm²) - 특정 규격 검토 시 필수
  final double? cableSizeSq;

  /// 절연체 종류 (PVC/XLPE)
  final InsulationType insulationType;

  /// 도체 재질 (구리/알루미늄)
  final ConductorType conductorType;

  /// 공사 방법 코드 (예: 'A1', 'C', 'D1')
  final String constructionCode;

  /// 주위 온도 (℃)
  final int ambientTemperature;

  /// 회로 수 (복수 회로 보정용)
  final int numberOfCircuits;

  /// 도체 가닥 수 (단상=2, 3상=3) - KEC 테이블 조회용
  final int conductorCount;

  /// 병렬 도체 수 (기본 1)
  final int parallelConductors;

  const CableCapacityParams({
    this.cableSizeSq,
    required this.insulationType,
    required this.conductorType,
    required this.constructionCode,
    required this.ambientTemperature,
    this.numberOfCircuits = 1,
    this.conductorCount = 3, // 기본 3상 가정
    this.parallelConductors = 1,
  });
}

/// 케이블 허용전류 계산 결과
class CableCapacityResult {
  /// 선정된(또는 입력된) 케이블 굵기 (mm²)
  final double cableSizeSq;

  /// 기본 허용전류 (Table Base Iz) (A)
  final double baseIz;

  /// 온도 보정 계수 (k1)
  final double tempCorrectionFactor;

  /// 집합(복수회로) 보정 계수 (k2)
  final double groupingCorrectionFactor;

  /// 최종 보정된 허용전류 (Adjusted Iz) (A)
  /// 공식: BaseIz * k1 * k2 * Parallel
  final double adjustedIz;

  const CableCapacityResult({
    required this.cableSizeSq,
    required this.baseIz,
    required this.tempCorrectionFactor,
    required this.groupingCorrectionFactor,
    required this.adjustedIz,
  });

  @override
  String toString() {
    return 'CableCapacityResult(Size: ${cableSizeSq}mm², Iz: ${adjustedIz.toStringAsFixed(1)}A '
        '[Base: $baseIz, k1: $tempCorrectionFactor, k2: $groupingCorrectionFactor])';
  }
}
