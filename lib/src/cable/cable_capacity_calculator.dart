import '../common/constants.dart';
import '../common/enums.dart';
import 'cable_models.dart';

/// 케이블 허용전류 계산기 (Safe Calculator)
class CableCapacityCalculator {
  /// 특정 케이블 규격에 대한 허용전류 계산
  static CableCapacityResult calculate(CableCapacityParams params) {
    if (params.cableSizeSq == null) {
      throw ArgumentError(
        'params.cableSizeSq is required for direct calculation.',
      );
    }

    final double size = params.cableSizeSq!;

    // 1. 기본 허용전류 (Base Iz) 가져오기
    final double baseIz = _getBaseIz(
      size,
      params.insulationType,
      params.constructionCode,
      params.conductorCount,
    );

    // 2. 온도 보정 계수 (k1)
    final double k1 = _getTempCorrectionFactor(
      params.insulationType,
      params.constructionCode,
      params.ambientTemperature,
    );

    // 3. 집합 보정 계수 (k2)
    final double k2 = _getGroupingCorrectionFactor(
      params.constructionCode,
      params.numberOfCircuits,
    );

    // 4. 최종 허용전류 계산
    // Adjusted = Base * k1 * k2 * Parallel
    final double adjustedIz = baseIz * k1 * k2 * params.parallelConductors;

    return CableCapacityResult(
      cableSizeSq: size,
      baseIz: baseIz,
      tempCorrectionFactor: k1,
      groupingCorrectionFactor: k2,
      adjustedIz: adjustedIz,
    );
  }

  /// 필요 전류(targetCurrent)를 만족하는 최소 케이블 굵기 선정
  static CableCapacityResult selectMinCableSize({
    required double targetCurrent,
    required CableCapacityParams params,
  }) {
    // 표준 규격 순회
    for (final size in kStandardCableSizes) {
      // 굵기만 바꿔서 params 복제
      final currentParams = CableCapacityParams(
        cableSizeSq: size,
        insulationType: params.insulationType,
        conductorType: params.conductorType,
        constructionCode: params.constructionCode,
        ambientTemperature: params.ambientTemperature,
        numberOfCircuits: params.numberOfCircuits,
        conductorCount: params.conductorCount,
        parallelConductors: params.parallelConductors,
      );

      final result = calculate(currentParams);

      if (result.adjustedIz >= targetCurrent) {
        return result; // 조건 만족 시 반환
      }
    }

    // 만족하는 규격이 없으면 가장 큰 규격 반환 (또는 예외 처리)
    // 여기서는 가장 큰 규격 계산 결과 반환 (Warning은 호출자가 처리)
    final maxSize = kStandardCableSizes.last;
    return calculate(
      CableCapacityParams(
        cableSizeSq: maxSize,
        insulationType: params.insulationType,
        conductorType: params.conductorType,
        constructionCode: params.constructionCode,
        ambientTemperature: params.ambientTemperature,
        numberOfCircuits: params.numberOfCircuits,
        conductorCount: params.conductorCount,
        parallelConductors: params.parallelConductors,
      ),
    );
  }

  // --- Internal Helper Methods (Legacy Logic Ported) ---

  static double _getBaseIz(
    double size,
    InsulationType insulation,
    String code,
    int conductors,
  ) {
    final spec = kCableSpecs[size];
    if (spec == null) return 0.0;

    final izMap =
        spec['iz'] as Map<InsulationType, Map<String, Map<String, dynamic>>>?;
    if (izMap == null) return 0.0;

    final insulationMap = izMap[insulation];
    if (insulationMap == null) return 0.0;

    // 공사방법 코드 (예: A1) 매핑
    // 데이터 구조상 'A1', 'B1' 등의 키를 사용함
    String lookupCode = code;

    // [New Logic Backport] 단심 케이블 + 공사방법 'E'(트레이)인 경우
    // -> 'F' 테이블(밀착 포설) 값을 사용하도록 매핑 변경
    if (conductors == 1 && code == 'E') {
      lookupCode = 'F';
    } else if (conductors > 1 && code == 'F') {
      // 반대로 다심 케이블은 F(밀착) 개념이 없으므로 E(트레이)로 매핑 (안전장치)
      lookupCode = 'E';
    }

    final methodMap = insulationMap[lookupCode];
    if (methodMap == null) return 0.0;

    final val = methodMap[conductors.toString()];
    return (val as num?)?.toDouble() ?? 0.0;
  }

  static double _getTempCorrectionFactor(
    InsulationType insulation,
    String code,
    int temp,
  ) {
    // D1, D2는 'Ground', 나머지는 'Air' (Legacy Logic)
    final environment = (code == 'D1' || code == 'D2')
        ? InstallationType.ground
        : InstallationType.air;

    final typeMap = kTempCorrectionFactors[insulation];
    if (typeMap == null) return 1.0;

    final envMap = typeMap[environment];
    if (envMap == null) return 1.0;

    // 온도 범위 찾기: 입력 온도보다 크거나 같은 첫 번째 키값 (Safe lookup)
    final keys = envMap.keys.toList()..sort();
    final targetKey = keys.firstWhere(
      (t) => t >= temp,
      orElse: () => keys.last,
    );

    return envMap[targetKey] ?? 1.0;
  }

  static double _getGroupingCorrectionFactor(String code, int circuits) {
    if (circuits <= 1) return 1.0;

    // Grouping Logic map (Legacy)
    // 'A1','A2','B1','B2' -> Embedded
    // 'C' -> Surface
    // 'D1' -> GroundDuct
    // 'D2' -> GroundDirect
    // 'E','F','G' -> Tray (Default)

    String groupKey = 'Tray';
    if (['A1', 'A2', 'B1', 'B2'].contains(code)) {
      groupKey = 'Embedded';
    } else if (code == 'C') {
      groupKey = 'Surface';
    } else if (code == 'D1') {
      groupKey = 'GroundDuct';
    } else if (code == 'D2') {
      groupKey = 'GroundDirect';
    } else if (['E', 'F', 'G'].contains(code)) {
      groupKey = 'Tray';
    }

    final groupMap =
        kGroupingCorrectionFactors[groupKey] ??
        kGroupingCorrectionFactors['Tray']!;

    final keys = groupMap.keys.toList()..sort();
    // 회로 수보다 크거나 같은 첫 번째 키값
    final targetKey = keys.firstWhere(
      (k) => k >= circuits,
      orElse: () => keys.last,
    );

    return groupMap[targetKey] ?? 1.0;
  }
}
