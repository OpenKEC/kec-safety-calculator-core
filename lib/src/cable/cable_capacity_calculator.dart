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
      params.isSingleCore,
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
      params.isSingleCore,
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
        isSingleCore: params.isSingleCore,
      );

      final result = calculate(currentParams);

      if (result.adjustedIz >= targetCurrent) {
        return result; // 조건 만족 시 반환
      }
    }

    // 만족하는 규격이 없으면 가장 큰 규격 반환 (또는 예외 처리)
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
        isSingleCore: params.isSingleCore,
      ),
    );
  }

  // --- Internal Helper Methods ---

  static double _getBaseIz(
    double size,
    InsulationType insulation,
    String code,
    int conductors,
    bool isSingleCore,
  ) {
    final spec = kCableSpecs[size];
    if (spec == null) return 0.0;

    // Type casting logic for dynamic map
    final izMap = spec['iz'];
    if (izMap is! Map) return 0.0;
    
    final insulationMap = izMap[insulation];
    if (insulationMap is! Map) return 0.0;

    // 공사방법 코드 (예: A1) 매핑
    String lookupCode = code;

    // [Logic Update] 단심 케이블 + 공사방법 'E'(트레이)인 경우
    // 'F' 테이블(밀착 포설, Spaced) 값을 사용하도록 매핑 변경
    if (isSingleCore && code == 'E') {
      lookupCode = 'F';
    } 
    // 다심 케이블은 F(밀착) 개념이 없으므로 E(트레이)로 매핑 (User Safety)
    else if (!isSingleCore && code == 'F') {
      lookupCode = 'E';
    }

    final methodMap = insulationMap[lookupCode];
    if (methodMap is! Map) {
         // Fallback if 'F' not found, verify if 'E' exists
         if (lookupCode == 'F' && code == 'E') {
             final fallback = insulationMap['E'];
             if(fallback is Map) {
                 return (fallback[conductors.toString()] as num?)?.toDouble() ?? 0.0;
             }
         }
         return 0.0;
    }

    final val = methodMap[conductors.toString()];
    return (val as num?)?.toDouble() ?? 0.0;
  }

  static double _getTempCorrectionFactor(
    InsulationType insulation,
    String code,
    int temp,
  ) {
    // D1, D2는 'Ground', 나머지는 'Air'
    final environment = (code == 'D1' || code == 'D2')
        ? InstallationType.ground
        : InstallationType.air;

    final typeMap = kTempCorrectionFactors[insulation];
    if (typeMap == null) return 1.0;

    final envMap = typeMap[environment];
    if (envMap == null) return 1.0;

    // Key가 정수형 온도(5단위)라고 가정하고, 입력 온도보다 크거나 같은 첫 번째 키 찾기 (없으면 Last)
    final keys = envMap.keys.toList()..sort();
    
    // 단순화된 로직: 정확히 일치 없으면 올림 처리
    // 예: temp=32 -> 35
    final targetTemp = keys.firstWhere(
      (t) => t >= temp,
      orElse: () => keys.last,
    );

    return envMap[targetTemp] ?? 1.0;
  }

  static double _getGroupingCorrectionFactor(
    String code,
    int circuits,
    bool isSingleCore,
  ) {
    // 1회선이면 보정 없음
    if (circuits <= 1) return 1.0;

    // 공사 방법에 따른 그룹 키 매핑
    String groupKey;
    if (['A1', 'A2', 'B1', 'B2'].contains(code)) {
      groupKey = 'Embedded';
    } else if (code == 'C') {
      groupKey = 'Surface';
    } else if (code == 'D1') {
      groupKey = 'GroundDuct';
    } else if (code == 'D2') {
      groupKey = 'GroundDirect';
    } else {
      // Tray (E, F)
      // 단심이면 SingleLayer, 다심이면 MultiCore(Tray)
      // 여기서는 KEC 표준 표에 따라 'Tray'로 통칭하되 상세 분리 가능
      groupKey = 'Tray';
    }

    final groupMap = kGroupingCorrectionFactors[groupKey];
    if (groupMap == null) return 1.0; // Default

    final keys = groupMap.keys.toList()..sort();
    final targetCircuits = keys.firstWhere(
      (c) => c >= circuits,
      orElse: () => keys.last,
    );

    return groupMap[targetCircuits] ?? 1.0;
  }
}
