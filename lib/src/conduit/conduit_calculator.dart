import 'dart:math';
import '../common/constants.dart';
import '../common/enums.dart';

/// 전선관 계산 파라미터
class ConduitParams {
  /// 메인 전선 단면적 (mm²)
  final double mainWireSizeSq;

  /// 메인 전선 가닥 수
  final int mainWireCount;

  /// 메인 전선 타입 (IV/CV) (단심/다심 구분용)
  final CableCoreType mainWireType;

  /// 접지선 단면적 (mm²) (선택)
  final double? earthWireSizeSq;

  /// 접지선 가닥 수
  final int earthWireCount;

  /// 접지선 타입 (보통 IV)
  final CableCoreType earthWireType;

  const ConduitParams({
    required this.mainWireSizeSq,
    required this.mainWireCount,
    required this.mainWireType,
    this.earthWireSizeSq,
    this.earthWireCount = 0,
    this.earthWireType = CableCoreType.single, // Default IV
  });
}

/// 전선관 추천 상세 결과 (단일 파이프 타입에 대한)
class ConduitRecommendation {
  /// 파이프 종류 (예: "HI-PVC")
  final String typeLabel;

  /// 선정된 규격 (호칭)
  final int size;

  /// 파이프 내단면적 (mm²)
  final double innerArea;

  /// 점유율 (%) (총 전선 단면적 / 파이프 내단면적)
  final double occupancyRate;

  /// 안전 여부 (32% 이하)
  final bool isSafe;

  /// 한 단계 작은 규격 (경고용) - 있다면
  final int? disallowedSize;

  /// 한 단계 작은 규격일 때의 점유율 (경고용)
  final double? disallowedOccupancy;

  const ConduitRecommendation({
    required this.typeLabel,
    required this.size,
    required this.innerArea,
    required this.occupancyRate,
    required this.isSafe,
    this.disallowedSize,
    this.disallowedOccupancy,
  });
}

/// 전선관 계산 전체 결과
class ConduitCalculationResult {
  /// 총 전선 단면적 합계 (피복 포함) (mm²)
  final double totalWireArea;

  /// 각 파이프 종류별 추천 결과 리스트
  final List<ConduitRecommendation> recommendations;

  /// 전문가 팁 (한 단계 큰 규격 추천 등)
  final String expertTip;

  const ConduitCalculationResult({
    required this.totalWireArea,
    required this.recommendations,
    required this.expertTip,
  });
}

/// 전선관 굵기 계산기
class ConduitCalculator {
  static const double _maxSafeOccupancy = 32.0;

  /// 상세 전선관 규격 선정 계산 (모든 파이프 타입 검토)
  static ConduitCalculationResult calculateDetailed(ConduitParams params) {
    // 1. 총 단면적 계산 (Total Wire Area)
    // 메인 전선
    final mainODMap = (params.mainWireType == CableCoreType.multi)
        ? kCableOuterDiameters
        : kSingleCoreCableOuterDiameters;

    final mainOD = mainODMap[params.mainWireSizeSq] ?? 10.0; // Fallback 10mm
    final mainArea = params.mainWireCount * pow(mainOD, 2) * pi / 4;

    // 접지선
    double earthArea = 0;
    if (params.earthWireSizeSq != null && params.earthWireCount > 0) {
      final earthODMap = (params.earthWireType == CableCoreType.multi)
          ? kCableOuterDiameters
          : kSingleCoreCableOuterDiameters;

      final earthOD = earthODMap[params.earthWireSizeSq] ?? 6.0;
      earthArea = params.earthWireCount * pow(earthOD, 2) * pi / 4;
    }

    final totalWireArea = mainArea + earthArea;

    // 2. 각 파이프 타입별 추천 계산
    final List<ConduitRecommendation> recommendations = [];

    // Helper function
    ConduitRecommendation calcByType(
        String label, Map<int, double> conduitMap) {
      final sortedSizes = conduitMap.keys.toList()..sort();

      int recommendedSize = sortedSizes.last;
      double recommendedInnerArea = 0;
      double recommendedOccupancy = 0;

      int? warningSize;
      double? warningOccupancy;

      for (int i = 0; i < sortedSizes.length; i++) {
        final size = sortedSizes[i];
        final id = conduitMap[size]!; // Inner Diameter
        final innerArea = pow(id, 2) * pi / 4;
        final occupancy = (totalWireArea / innerArea) * 100.0;

        if (occupancy <= _maxSafeOccupancy) {
          recommendedSize = size;
          recommendedInnerArea = innerArea;
          recommendedOccupancy = occupancy;

          // Check previous (smaller) size for warning context
          if (i > 0) {
            final prevSize = sortedSizes[i - 1];
            final prevId = conduitMap[prevSize]!;
            final prevArea = pow(prevId, 2) * pi / 4;
            final prevOcc = (totalWireArea / prevArea) * 100.0;

            if (prevOcc > _maxSafeOccupancy) {
              warningSize = prevSize;
              warningOccupancy = prevOcc;
            }
          }
          break;
        }
      }

      return ConduitRecommendation(
        typeLabel: label,
        size: recommendedSize,
        innerArea: recommendedInnerArea,
        occupancyRate: recommendedOccupancy,
        isSafe: recommendedOccupancy <= _maxSafeOccupancy,
        disallowedSize: warningSize,
        disallowedOccupancy: warningOccupancy,
      );
    }

    recommendations
        .add(calcByType('HI-PVC (경질비닐 - 딱딱한 파이프)', kConduitInnerDiameters));
    recommendations
        .add(calcByType('스틸 (금속관 - 튼튼한 철 파이프)', kSteelConduitInnerDiameters));
    recommendations
        .add(calcByType('ELP (지중전선관 - 땅에 묻는 주름관)', kElpConduitInnerDiameters));
    recommendations.add(calcByType(
        'SF/GW (가요전선관 - 잘 휘는 후렉시블)', kFlexibleConduitInnerDiameters));
    recommendations
        .add(calcByType('CD관 (합성수지관 - 콘크리트 매립용)', kCdConduitInnerDiameters));

    // 3. Expert Tip 생성
    // Legacy logic: "30m 이상 or 굴곡 3개소 이상 시 한 단계 큰 규격 사용 권장"
    // Use first recommendation (HI-PVC) as baseline for the tip.
    final primary = recommendations.first;
    String tipMsg =
        "배관 길이가 30m를 넘거나 굴곡이 3개소 이상인 경우, 시공 편의성을 위해 한 단계 큰 규격 사용을 권장합니다.";

    final pvcSizes = kConduitInnerDiameters.keys.toList()..sort();
    final idx = pvcSizes.indexOf(primary.size);
    if (idx != -1 && idx < pvcSizes.length - 1) {
      final nextSize = pvcSizes[idx + 1];
      tipMsg =
          "배관 길이가 30m를 넘거나 굴곡이 3개소 이상인 경우, 시공 편의성을 위해 한 단계 큰 ${nextSize}C 사용을 권장합니다.";
    }

    return ConduitCalculationResult(
      totalWireArea: totalWireArea,
      recommendations: recommendations,
      expertTip: tipMsg,
    );
  }
}
