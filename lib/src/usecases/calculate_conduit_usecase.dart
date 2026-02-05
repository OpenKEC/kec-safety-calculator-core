import 'package:kec_safety_calculator_core/src/data/sources/static_cable_data.dart';

class ConduitRecommendation {
  final String typeLabel;
  final num size;
  final double innerArea;
  final double occupancyRate;
  final bool isSafe;

  ConduitRecommendation({
    required this.typeLabel,
    required this.size,
    required this.innerArea,
    required this.occupancyRate,
    required this.isSafe,
  });
}

class ConduitCalculationResult {
  final double totalWireArea;
  final List<ConduitRecommendation> recommendations;
  final String? expertTip;

  ConduitCalculationResult({
    required this.totalWireArea,
    required this.recommendations,
    this.expertTip,
  });
}

class CalculateConduitUseCase {
  ConduitCalculationResult? execute({
    required String wireType, // 'CV' or 'IV'
    required double mainSq,
    required int mainCount, // 2, 3, 4 (가닥수)
    required bool includeEarth,
    required String earthWireType,
    required double earthSq,
    required int earthCount, // usually 1
    required int coreCount, // [New] 1, 2, 3, 4 (코어수)
  }) {
    // 1. Get diameters for Main Wires
    double mainDiameter = 0.0;

    if (wireType == 'CV') {
      // F-CV (케이블): 코어수에 따른 외경 적용
      final map = kFcvCableOuterDiameters[coreCount] ?? kCableOuterDiameters;
      mainDiameter = map[mainSq] ?? 0.0;
    } else if (wireType == 'VCTF') {
      // [New] VCTF (연질 비닐 코드)
      final map = kVctfCableOuterDiameters[coreCount] ??
          kVctfCableOuterDiameters[3]!; // Default to 3C if unknown
      mainDiameter = map[mainSq] ?? 0.0;
    } else {
      // IV (절연전선): 기존 단심 데이터 적용
      // (IV는 물리적으로 1C만 존재하므로 coreCount와 무관하게 Single Core 적용)
      mainDiameter = kSingleCoreCableOuterDiameters[mainSq] ?? 0.0;
    }

    // Area = (d^2 * pi) / 4
    // But commonly calculated as sum of outer areas.
    // KEC: Total cross-sectional area of wires (including insulation)
    final mainOneArea = (mainDiameter * mainDiameter * 3.14159) / 4;
    final totalMainArea = mainOneArea * mainCount;

    // 2. Get diameters for Earth Wires
    double totalEarthArea = 0.0;
    if (includeEarth && earthCount > 0) {
      final earthDiameterMap = (earthWireType == 'CV')
          ? kCableOuterDiameters
          : kSingleCoreCableOuterDiameters;
      final earthDiameter = earthDiameterMap[earthSq] ?? 0.0;
      final earthOneArea = (earthDiameter * earthDiameter * 3.14159) / 4;
      totalEarthArea = earthOneArea * earthCount;
    }

    final totalWireArea = totalMainArea + totalEarthArea;

    // 3. Evaluate against Conduit Types
    final conduitSpecs = {
      'HI-PVC (경질비닐)': kConduitInnerDiameters,
      '스틸 (금속관)': kSteelConduitInnerDiameters,
      'ELP (지중전선관)': kElpConduitInnerDiameters,
      'SF/GW (가요전선관)': kFlexibleConduitInnerDiameters,
      'CD관 (합성수지관)': kCdConduitInnerDiameters,
    };

    final recommendations = <ConduitRecommendation>[];

    conduitSpecs.forEach((typeLabel, sizesMap) {
      // Find smallest size where (totalWireArea / innerArea) <= 0.32
      // Inner Area = (d_in^2 * pi) / 4

      num? bestSize;
      double? bestInnerArea;
      double? bestOccupancy;

      final sortedSizes = sizesMap.keys.toList()..sort();

      for (final size in sortedSizes) {
        final innerDia = sizesMap[size]!.toDouble();
        final innerArea = (innerDia * innerDia * 3.14159) / 4;
        final occupancy = (totalWireArea / innerArea) * 100;

        if (occupancy <= 32.0) {
          bestSize = size;
          bestInnerArea = innerArea;
          bestOccupancy = occupancy;
          break; // Found smallest fit
        }
      }

      // If no fit found, take the largest available
      if (bestSize == null) {
        final largestSize = sortedSizes.last;
        final innerDia = sizesMap[largestSize]!.toDouble();
        final innerArea = (innerDia * innerDia * 3.14159) / 4;
        final occupancy = (totalWireArea / innerArea) * 100;

        bestSize = largestSize;
        bestInnerArea = innerArea;
        bestOccupancy = occupancy;
      }

      recommendations.add(ConduitRecommendation(
        typeLabel: typeLabel,
        size: bestSize,
        innerArea: bestInnerArea!,
        occupancyRate: bestOccupancy!,
        isSafe: bestOccupancy <= 32.0,
      ));
    });

    // 4. Expert Tip
    String? expertTip;
    // Example logic from original service
    if (totalWireArea > 0) {
      expertTip = '메인 전선 $mainCount가닥';
      if (includeEarth) expertTip += ' + 접지선 $earthCount가닥';
      expertTip += '\n총 단면적: ${totalWireArea.toStringAsFixed(1)}mm²';
    }

    return ConduitCalculationResult(
      totalWireArea: totalWireArea,
      recommendations: recommendations,
      expertTip: expertTip,
    );
  }
}
