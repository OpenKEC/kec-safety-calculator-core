import 'dart:math';
import 'package:kec_safety_calculator_core/src/data/sources/static_cable_data.dart';
import 'package:kec_safety_calculator_core/src/models/calculation_input.dart';
import 'package:kec_safety_calculator_core/src/models/calculation_result.dart';
import 'package:kec_safety_calculator_core/src/repositories/cable_repository.dart';

/// [Architect Note] 모든 계산 로직은 Domain Service에서 관리하며 UI와 철저히 분리됩니다.
class KecCalculatorService {
  final CableRepository _cableRepository;
  KecCalculatorService(this._cableRepository);

  // 기본 상수
  static const double _defaultMotorLoadFactor = 1.25;
  static const double _allowedVoltageDropPercent = 3.0;
  static const double _defaultPhaseVoltage = 220.0; // 기본 상전압(단상/3상 계산용 기본값)

  /// KEC 232.3.9 전압강하 허용률 계산
  /// [isHighVoltage]: 고압 수전 여부 (true: 고압, false: 저압)
  /// [isLighting]: 조명 부하 여부 (true: 조명, false: 기타)
  /// [length]: 선로 길이 (m)
  double calculateAllowedVoltageDropRate({
    required bool isHighVoltage,
    required bool isLighting,
    required double length,
  }) {
    // 1. 기본 허용률 (표 232.3-1)
    // A. 저압수전: 조명 3%, 기타 5%
    // B. 고압수전: 조명 6%, 기타 8%
    double baseRate;
    if (isHighVoltage) {
      baseRate = isLighting ? 6.0 : 8.0;
    } else {
      baseRate = isLighting ? 3.0 : 5.0;
    }

    // 2. 거리 가산 (100m 초과 시 미터당 0.005% 가산, 최대 0.5%)
    double distanceAddition = 0.0;
    if (length > 100) {
      double extraMeters = length - 100;
      distanceAddition = extraMeters * 0.005;
      if (distanceAddition > 0.5) distanceAddition = 0.5;
    }

    return baseRate + distanceAddition;
  }

  // 1. 전선 허용전류 계산 (KEC 2024 규정 기반, Public API)
  Future<double> calculateAllowableCurrent({
    required double size,
    required String insulation,
    required String standardCode,
    required int temperature,
    required int circuits,
    required String environment, // '공기' 또는 '지중'
    bool isNeutralHarmonic = false,
  }) async {
    final specs = await _cableRepository.getCableSpecs(size);
    if (specs == null) return 0.0;

    // 방어적으로 맵 구조를 검사합니다.
    final izDynamic = specs['iz'];
    if (izDynamic == null || izDynamic is! Map) return 0.0;
    final izMap = izDynamic as Map<String, dynamic>;
    final insulationDynamic = izMap[insulation];
    if (insulationDynamic == null || insulationDynamic is! Map) return 0.0;
    final insulationMap = insulationDynamic as Map<String, dynamic>;
    final methodDynamic = insulationMap[standardCode];
    if (methodDynamic == null || methodDynamic is! Map) return 0.0;
    final methodMap = methodDynamic as Map<String, dynamic>;
    final nominalRaw = methodMap['3'] ??
        methodMap.values.firstWhere((v) => v != null, orElse: () => null);
    if (nominalRaw == null) return 0.0;
    final double nominalIz = (nominalRaw as num).toDouble();

    // 온도 보정
    final tempFactors =
        (kTemperatureCorrectionFactors[insulation] is Map<int, double>)
            ? kTemperatureCorrectionFactors[insulation]!
            : <int, double>{};
    final roundedTemp = (temperature / 5).round() * 5;
    final tempFactor = tempFactors[roundedTemp] ??
        (tempFactors.values.isNotEmpty ? tempFactors.values.last : 1.0);

    // 집합 보정
    // 집합보정은 static_cable_data.dart의 kGroupingCorrectionFactors를 사용하여
    // 표준코드(standardCode)에 따른 그룹 유형을 구한 뒤 해당 회로수에 맞는 보정계수를 적용합니다.
    final groupKey = _getGroupKeyByStandardCode(standardCode);
    final groupMap = kGroupingCorrectionFactors[groupKey] ??
        kGroupingCorrectionFactors['Tray']!;
    final sortedKeys = groupMap.keys.toList()..sort();
    final targetKey = sortedKeys.firstWhere((k) => k >= circuits,
        orElse: () => sortedKeys.last);
    final groupFactor = groupMap[targetKey] ?? 1.0;

    return nominalIz *
        tempFactor *
        groupFactor *
        (isNeutralHarmonic ? 0.86 : 1.0);
  }

  // 2. 통합 전선 굵기 선정 (메인 진입점)
  Future<CalculationResult> calculate(CalculationInput input) async {
    return _performFullCalculation(input);
  }

  // 3. 전압강하 계산 (Public API)
  double calculateVoltageDrop({
    required double voltage,
    required double current,
    required double length,
    required double resistance,
    required double reactance,
    required double powerFactor,
    required String wiringMethod,
  }) {
    double k = (wiringMethod == '단상 2선식')
        ? 2.0
        : (wiringMethod.contains('3상') ? sqrt(3) : 1.0);
    double sinTheta = sqrt(1 - pow(powerFactor, 2));
    return k *
        current *
        (resistance * powerFactor + reactance * sinTheta) *
        (length / 1000);
  }

  // 4. 단락전류 계산 (Public API)
  double calculateShortCircuitCurrent({
    required double kva,
    required double voltage,
    required double impedancePercent,
    bool isThreePhase = true,
  }) {
    // 인입단에서의 단락전류를 kA 단위로 반환합니다.
    // 정격전류 iRated는 A 단위이며, 최종 결과는 1000으로 나누어 kA로 반환됩니다.
    double iRated = isThreePhase
        ? (kva * 1000) / (sqrt(3) * voltage)
        : (kva * 1000) / voltage;
    if (impedancePercent <= 0) return 0.0;
    return (100 / impedancePercent) * iRated / 1000; // kA
  }

  // 5. 접지선 굵기 (KEC 142.3.2)
  double calculateEarthingSize(double s) {
    if (s <= 16) return s;
    if (s <= 35) return 16;
    return s / 2;
  }

  double calculateEarthingConductorSize(double s) => calculateEarthingSize(s);
  double calculateEarthWireSize(double s) => calculateEarthingSize(s);

  // 6. 전선관 상세 선정
  LegacyConduitCalculationResult calculateDetailedConduit({
    required double mainSq,
    required int mainCount,
    required String wireType,
    double? earthSq,
    String earthWireType = 'IV',
    int earthCount = 0,
  }) {
    final diameterMap = (wireType == 'CV')
        ? kCableOuterDiameters
        : kSingleCoreCableOuterDiameters;
    final mainOD = diameterMap[mainSq] ?? 10.0;
    final mainArea = mainCount * pow(mainOD, 2) * pi / 4;

    double earthArea = 0;
    if (earthSq != null && earthCount > 0) {
      final earthDiameterMap = (earthWireType == 'CV')
          ? kCableOuterDiameters
          : kSingleCoreCableOuterDiameters;
      final earthOD = earthDiameterMap[earthSq] ?? 6.0;
      earthArea = earthCount * pow(earthOD, 2) * pi / 4;
    }

    final totalWireArea = mainArea + earthArea;
    final List<LegacyConduitRecommendation> recommendations = [];

    LegacyConduitRecommendation calcByType(
        String label, Map<int, double> conduitMap) {
      final sortedSizes = conduitMap.keys.toList()..sort();
      int recommendedSize = sortedSizes.last;
      double recommendedInnerArea = 0;
      double recommendedOccupancy = 0;
      int? warningSize;
      double? warningOccupancy;

      for (int i = 0; i < sortedSizes.length; i++) {
        final size = sortedSizes[i];
        final id = conduitMap[size]!;
        final innerArea = pow(id, 2) * pi / 4;
        final occupancy = (totalWireArea / innerArea) * 100;

        if (occupancy <= 32.0) {
          recommendedSize = size;
          recommendedInnerArea = innerArea;
          recommendedOccupancy = occupancy;
          if (i > 0) {
            final prevSize = sortedSizes[i - 1];
            final prevId = conduitMap[prevSize]!;
            final prevArea = pow(prevId, 2) * pi / 4;
            final prevOcc = (totalWireArea / prevArea) * 100;
            if (prevOcc > 32.0) {
              warningSize = prevSize;
              warningOccupancy = prevOcc;
            }
          }
          break;
        }
      }
      return LegacyConduitRecommendation(
        typeLabel: label,
        size: recommendedSize,
        innerArea: recommendedInnerArea,
        occupancyRate: recommendedOccupancy,
        isSafe: recommendedOccupancy <= 32.0,
        disallowedSize: warningSize,
        disallowedOccupancy: warningOccupancy,
      );
    }

    recommendations.add(calcByType('HI-PVC (경질비닐)', kConduitInnerDiameters));
    recommendations.add(calcByType('스틸 (금속관)', kSteelConduitInnerDiameters));
    recommendations.add(calcByType('ELP (지중전선관)', kElpConduitInnerDiameters));
    recommendations
        .add(calcByType('SF/GW (가요전선관)', kFlexibleConduitInnerDiameters));
    recommendations.add(calcByType('CD관 (합성수지관)', kCdConduitInnerDiameters));

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

    return LegacyConduitCalculationResult(
      recommendations: recommendations,
      expertTip: tipMsg,
      totalWireArea: totalWireArea,
    );
  }

  // 7. 분전반 용량 검토
  Map<String, dynamic> checkPanelCapacity({
    required double mainBreakerRating,
    required double existingLoadCurrent,
    required double newLoadCurrent,
  }) {
    final total = existingLoadCurrent + newLoadCurrent;
    final isSafe = total < mainBreakerRating;
    final margin = mainBreakerRating - total;
    return {
      'isSafe': isSafe,
      'mainBreakerRating': mainBreakerRating,
      'totalLoad': total,
      'margin': margin,
    };
  }

  // 8. 유틸리티: 전력-전류 변환
  double calculateCurrentFromPower(
      double kw, double voltage, bool isThreePhase) {
    if (isThreePhase) return (kw * 1000) / (sqrt(3) * voltage);
    return (kw * 1000) / voltage;
  }

  double calculateShortCircuitCurrentHelper(
      double kva, double voltage, double impedance,
      [bool isThreePhase = true]) {
    return calculateShortCircuitCurrent(
        kva: kva,
        voltage: voltage,
        impedancePercent: impedance,
        isThreePhase: isThreePhase);
  }

  /// Wrapper: 변압기 명판 정보(`kva`, `voltage`, `impedancePercent`)와
  /// 선택 항목인 `xrRatio` (전원의 X/R 비)를 사용하여 부하 말단의 감쇄된 단락전류를 계산합니다.
  /// 주어진 전압을 기준으로 변압기의 테브난(Thevenin) 임피던스를 옴(ohm) 단위로 계산하고,
  /// 이를 선로의 길이 임피던스와 결합하여 부하 말단의 단락전류(kA)를 산출합니다.
  double calculateReducedShortCircuitFromTransformer({
    required double kva,
    required double voltage,
    required double impedancePercent,
    required double length,
    required double sq,
    double? xrRatio,
    bool isThreePhase = true,
  }) {
    if (impedancePercent <= 0) {
      return calculateReducedShortCircuitCurrent(
          startKA: 0, length: length, sq: sq);
    }

    // 변압기 2차측 시작 단락전류 (kA)
    final startKA = calculateShortCircuitCurrent(
        kva: kva,
        voltage: voltage,
        impedancePercent: impedancePercent,
        isThreePhase: isThreePhase);

    // 주어진 전압 기준 변압기 등가 임피던스 (ohm).
    // 기준 임피던스 Z_base = V^2 / S (S는 VA). 따라서 Zth = Zpu * Z_base.
    final sVA = kva * 1000.0;
    final zBase = (voltage * voltage) / sVA; // ohm
    final zTh = (impedancePercent / 100.0) * zBase; // ohm

    double rSource = zTh;
    double xSource = 0.0;
    if (xrRatio != null && xrRatio > 0) {
      rSource = zTh / sqrt(1 + xrRatio * xrRatio);
      xSource = rSource * xrRatio;
    }

    // 케이블 테이블에 따른 선로 임피던스 (ohm/km -> 거리 적용 후 ohm)
    if (!kIecCableImpedanceData.containsKey(sq)) return startKA;
    final r = kIecCableImpedanceData[sq]![0];
    final x = kIecCableImpedanceData[sq]![1];
    final rLine = r * (length / 1000.0);
    final xLine = x * (length / 1000.0);

    final rTotal = rLine + rSource;
    final xTotal = xLine + xSource;
    final zTotal = sqrt(rTotal * rTotal + xTotal * xTotal);

    // Fault current at load end (A) = V / |Z_total|. Use the supplied voltage.
    if (zTotal <= 0) return 0.0;
    final loadAmps = voltage / zTotal;
    return loadAmps / 1000.0; // kA
  }

  // ------------------------------------------------------------------------
  // Private Helper Implementation
  // ------------------------------------------------------------------------

  Future<CalculationResult> _performFullCalculation(
      CalculationInput input) async {
    final reasoning = <String>[];
    final standardSizes = await _cableRepository.getStandardCableSizes();
    final standardBreakers =
        await _cableRepository.getStandardBreakerRatings(input.breakerType);

    reasoning.add(
        '[기본 조건] 도체:${input.conductorType}, 절연체:${input.insulationType}, 보호장치:${input.breakerType}, '
        '병렬도체수:${input.parallelConductors}가닥, 회로수:${input.numberOfCircuits}, '
        '모드:${input.isBreakerMode ? "차단기우선" : "부하용량기준"}');

    double ib = 0.0;
    double breakerCurrentRating = 0.0;
    double currentForVoltageDrop = 0.0;

    if (input.isBreakerMode) {
      ib = 0.0;
      breakerCurrentRating = input.inputBreakerA ?? 0.0;
      currentForVoltageDrop = breakerCurrentRating;
      reasoning.add('[Step 1] 설계전류(IB): 계산 생략 (차단기 용량 우선 모드)');
      reasoning.add('[Step 2] 차단기 선정: 사용자 지정 ${breakerCurrentRating}A');
    } else {
      ib = _calculateDesignCurrent(input, reasoning);
      double targetCurrentForBreakerSel = ib;
      if (input.isMotor) {
        final multiplier =
            input.motorStartingMultiplier ?? _defaultMotorLoadFactor;
        targetCurrentForBreakerSel = ib * multiplier;
      reasoning.add(
          '[상세 계산] └ 전동기 여유율 적용: ${ib.toStringAsFixed(2)}A x $multiplier = ${targetCurrentForBreakerSel.toStringAsFixed(2)}A');
      }
      final int selectedBreaker = _selectBreaker(
          targetCurrentForBreakerSel, standardBreakers, reasoning);
      breakerCurrentRating = selectedBreaker.toDouble();
      currentForVoltageDrop = ib;
    }

    final conductorCount = (input.wiringMethod == '단상') ? 2 : 3;
    final selectedMethod = kConstructionMethods.firstWhere(
        (m) => m.code == input.constructionMethodCode,
        orElse: () => kConstructionMethods.first);

    final tempCorrectionFactor = _calculateTempCorrectionFactor(
        input.insulationType,
        selectedMethod.standardCode,
        input.ambientTemperature,
        reasoning);

    final groupingFactor = _calculateGroupingCorrectionFactor(
        selectedMethod.standardCode,
        input.numberOfCircuits,
        input.isTightInstallation,
        reasoning);

    final totalCorrectionFactor = tempCorrectionFactor * groupingFactor;
    reasoning.add(
        '[보정계수] 총 보정계수 = ${tempCorrectionFactor.toStringAsFixed(2)} (온도) x ${groupingFactor.toStringAsFixed(2)} (집합) = ${totalCorrectionFactor.toStringAsFixed(2)}');

    double cableForCurrent = 0.0;
    if (!input.isBreakerMode) {
      cableForCurrent = await _selectCableForCurrent(
          ib,
          standardSizes,
          input.insulationType,
          selectedMethod.standardCode,
          conductorCount,
          totalCorrectionFactor,
          1.0,
          input.parallelConductors,
          input.isSingleCore,
          reasoning,
          'S_B (설계전류 기준)');
    }

    final cableForBreaker = await _selectCableForOverload(
        breakerCurrentRating.toInt(),
        standardSizes,
        input.insulationType,
        selectedMethod.standardCode,
        conductorCount,
        totalCorrectionFactor,
        1.0,
        input.parallelConductors,
        input.isSingleCore,
        reasoning);

    final cableForVoltageDrop = await _checkVoltageDrop(
        input,
        currentForVoltageDrop,
        cableForBreaker,
        standardSizes,
        input.parallelConductors,
        reasoning);

    double cableForMotorThermal = 0;
    double cableForMotorVoltageDrop = 0;

    if (input.isMotor) {
      final motorMultiplier =
          input.motorStartingMultiplier ?? _defaultMotorLoadFactor;
      // 수정: 메서드 시그니처와 일치하도록 isSingleCore 파라미터 추가
      cableForMotorThermal = await _checkMotorStart(
          ib,
          motorMultiplier,
          standardSizes,
          input.insulationType,
          selectedMethod.standardCode,
          conductorCount,
          totalCorrectionFactor,
          1.0,
          input.parallelConductors,
          input.isSingleCore,
          reasoning);
      cableForMotorVoltageDrop = await _checkVoltageDropForMotorStart(
          input,
          (input.isBreakerMode ? breakerCurrentRating : ib) * motorMultiplier,
          cableForMotorThermal,
          standardSizes,
          input.parallelConductors,
          reasoning);
    } else {
      reasoning.add('[Step 4] 일반 부하이므로 전동기 기동 내력 검토를 생략합니다.');
    }

    double cableForShortCircuit = 0;
    double rawMinSizeForShortCircuit = 0;
    final kFactor = _getKFactor(input.insulationType, input.ambientTemperature);

    double? calculatedKA;

    if (input.directLoadEndShortCircuitCurrent != null) {
      // [Case 1] 부하 말단 직접 입력 값 우선 사용
      calculatedKA = input.directLoadEndShortCircuitCurrent;
      reasoning.add('[Step 5] 단락 전류 내력 검토 (사용자 부하 말단 직접 입력):\n'
          ' - 입력값(부하단): ${calculatedKA?.toStringAsFixed(2)} kA (감쇄 계산 생략 - 변압기 2차측 미참조)\n');
    } else if (input.shortCircuitCurrent != null) {
      // [Case 2] 변압기 2차측 입력 시 감쇄 계산
      double mainShortCircuitKA = input.shortCircuitCurrent!;
      double distanceMeters = input.cableLength;
      double currentMaxSq = [
        cableForCurrent,
        cableForBreaker,
        cableForVoltageDrop,
        cableForMotorThermal,
        cableForMotorVoltageDrop
      ].reduce(max);

      calculatedKA = calculateReducedShortCircuitCurrent(
          startKA: mainShortCircuitKA,
          length: distanceMeters,
          sq: currentMaxSq);

      reasoning.add('[Step 5] 단락 전류 내력 검토:\n'
          ' - 상위단(입력값): $mainShortCircuitKA kA\n'
          ' - 부하단(분기선로 말단): ${calculatedKA.toStringAsFixed(2)} kA (분기선로 ${distanceMeters}m, ${currentMaxSq}mm² 반영)\n');
    } else {
      // [Case 3] 둘 다 없음
      reasoning.add('[Step 5] 단락전류 정보 없음 (생략)');
    }

    if (calculatedKA != null) {
      double duration = input.shortCircuitDuration ?? 0.1;
      double iSquareT = pow(calculatedKA * 1000, 2) * duration;
      rawMinSizeForShortCircuit = sqrt(iSquareT) / kFactor;

      reasoning.add(
          ' - 최소 굵기: ${rawMinSizeForShortCircuit.toStringAsFixed(2)}mm² (K=$kFactor, t=${duration}s, 부하단 전류 기준)');

      for (var size in standardSizes) {
        if (size >= rawMinSizeForShortCircuit) {
          cableForShortCircuit = size;
          break;
        }
      }
      if (cableForShortCircuit == 0) cableForShortCircuit = standardSizes.last;
    }

    final finalCableSize = [
      cableForCurrent,
      cableForBreaker,
      cableForVoltageDrop,
      cableForMotorThermal,
      cableForMotorVoltageDrop,
      cableForShortCircuit
    ].reduce(max);

    // [New] 최종 선정된 굵기에 대한 Iz 및 전압강하 재계산 (결과 표시용)
    final finalIz = (await _getIz(finalCableSize, input.insulationType,
            selectedMethod.standardCode, conductorCount, input.isSingleCore)) *
        totalCorrectionFactor *
        input.parallelConductors;

    // 전압강하 재계산
    double finalVoltageDropRate = 0;
    final specs = await _cableRepository.getCableSpecs(finalCableSize);
    if (specs != null) {
      final r = await _getResistance(finalCableSize, input.conductorType);
      final x = (specs['x'] as num?)?.toDouble() ?? 0;
      final sinTheta = sqrt(1 - pow(input.powerFactor, 2));
      final rParallel = r / input.parallelConductors;
      final xParallel = x / input.parallelConductors;
      final double vd = (input.wiringMethod == '3상')
          ? sqrt(3) *
              ib *
              (input.cableLength / 1000) *
              (rParallel * input.powerFactor + xParallel * sinTheta)
          : 2 *
              ib *
              (input.cableLength / 1000) *
              (rParallel * input.powerFactor + xParallel * sinTheta);
      finalVoltageDropRate = (vd / input.voltage) * 100;
    }

    // 결정 요인 판별 로직 추가
    String? dominantReason;
    if (finalCableSize == cableForCurrent) {
      dominantReason = "부하 설계전류 허용전류에 의해 결정됨";
    }
    if (finalCableSize == cableForBreaker) {
      dominantReason = "차단기 용량 보호를 위한 허용전류에 의해 결정됨";
    }
    if (finalCableSize == cableForVoltageDrop) {
      dominantReason = "허용 전압강하 제한에 의해 결정됨";
    }
    if (finalCableSize == cableForMotorThermal) {
      dominantReason = "전동기 기동 시 열적 내력에 의해 결정됨";
    }
    if (finalCableSize == cableForMotorVoltageDrop) {
      dominantReason = "전동기 기동 시 전압강하 제한에 의해 결정됨";
    }
    if (finalCableSize == cableForShortCircuit) {
      dominantReason = "단락전류 유입 시 열적 내력에 의해 결정됨";
    }

    reasoning.add('[Step 6] 최종 굵기 선정: 모든 조건을 만족하는 $finalCableSize mm²를 선정합니다.');

    return CalculationResult(
      finalCableSize: finalCableSize,
      finalBreakerRating: breakerCurrentRating.toInt(),
      reasoning: reasoning,
      shortCircuitCurrent: input.shortCircuitCurrent ?? 0.0,
      shortCircuitDuration: input.shortCircuitDuration ?? 0.0,
      minCableSizeForShortCircuit: rawMinSizeForShortCircuit,
      kFactor: kFactor,
      detailResults: {
        'S_B (설계전류)': cableForCurrent,
        'S_CB (차단기)': cableForBreaker,
        'S_VD% (전압강하)': cableForVoltageDrop,
        'S_SC (단락강도)': cableForShortCircuit,
        'S_MSTH (기동열적)': input.isMotor ? cableForMotorThermal : 0.0,
        'S_MSVD% (기동전압)': input.isMotor ? cableForMotorVoltageDrop : 0.0,
      },
      reducedShortCircuitCurrent: calculatedKA,
      dominantReason: dominantReason,
      iz: finalIz,
      ib: ib,
      voltageDropRate: finalVoltageDropRate,
    );
  }

  double calculateReducedShortCircuitCurrent(
      {required double startKA,
      required double length,
      required double sq,
      double? sourceImpedanceOhm}) {
    // startKA: 전원측 단락전류 (kA)
    // length: 전원부터 부하까지의 거리 (m)
    // sq: 도체의 단면적 (mm²)
    // 부하 말단에서의 감쇄된 단락전류를 kA 단위로 반환합니다.
    if (!kIecCableImpedanceData.containsKey(sq)) return startKA;
    final r = kIecCableImpedanceData[sq]![0];
    final x = kIecCableImpedanceData[sq]![1];
    const voltagePhase = _defaultPhaseVoltage; // 기본 상전압 상수 사용
    final startAmps = startKA * 1000; // kA를 A로 변환
    if (startAmps == 0) return 0.0;

    // 전원 임피던스 크기 (직렬로 가정)
    // 우선순위: 호출자가 `sourceImpedanceOhm`을 제공하면 이를 사용하고,
    // 없으면 기존의 보수적 추정치인 V/I를 사용합니다.
    final zSource = (sourceImpedanceOhm != null && sourceImpedanceOhm > 0)
        ? sourceImpedanceOhm
        : voltagePhase / startAmps; // ohm

    // 거리에 따른 선로 임피던스 (ohm)
    final rLine = r * (length / 1000); // r은 ohm/km 단위이므로 ohm으로 변환
    final xLine = x * (length / 1000); // x는 ohm/km 단위이므로 ohm으로 변환

    // 전체 직렬 임피던스: 전원 임피던스와 선로 저항/리액턴스의 직렬 합산.
    // zSource를 실제 직렬 저항으로 취급 (보수적 단순화).
    final rTotal = rLine + zSource;
    final xTotal = xLine;
    final zTotal = sqrt((rTotal * rTotal) + (xTotal * xTotal));

    // 부하 말단에서의 단락전류 (A) = V / |Z_total|
    final loadAmps = voltagePhase / zTotal;
    return loadAmps / 1000; // A를 kA로 변환
  }

  double _calculateTempCorrectionFactor(String insulation, String standardCode,
      int temperature, List<String> reasoning) {
    final environment =
        (standardCode == 'D1' || standardCode == 'D2') ? 'Ground' : 'Air';
    final typeMap =
        kTempCorrectionFactors[insulation] ?? kTempCorrectionFactors['XLPE']!;
    final envMap = typeMap[environment] ?? typeMap.values.first;
    final keys = envMap.keys.toList()..sort();
    final targetTemp =
        keys.firstWhere((t) => t >= temperature, orElse: () => keys.last);
    final factor = envMap[targetTemp] ?? 1.0;
    reasoning.add(
        '[온도보정] 주위온도 $temperature℃ (적용 $targetTemp℃, $environment, $insulation) -> 보정계수 k1=$factor');
    return factor;
  }

  double _calculateGroupingCorrectionFactor(
      String standardCode, int circuits, bool isTight, List<String> reasoning) {
    if (circuits <= 1 || !isTight) {
      // 이격 포설 또는 단일 회로 -> 보정 없음
      if (circuits > 1 && !isTight) {
        reasoning.add('[집합보정] $circuits회로 (이격 포설) -> 보정계수 k2=1.0 (감소 없음)');
      }
      return 1.0;
    }
    String groupKey = _getGroupKeyByStandardCode(standardCode);
    final groupMap = kGroupingCorrectionFactors[groupKey] ??
        kGroupingCorrectionFactors['Tray']!;
    final keys = groupMap.keys.toList()..sort();
    final targetKey =
        keys.firstWhere((k) => k >= circuits, orElse: () => keys.last);
    final factor = groupMap[targetKey] ?? 1.0;
    reasoning.add(
        '[집합보정] 동일 경로 $circuits회로 (적용 $targetKey회로, $groupKey, 밀착) -> 보정계수 k2=$factor');
    return factor;
  }

  Future<double> _selectCableForCurrent(
      double current,
      List<double> standardSizes,
      String insulation,
      String standardCode,
      int conductorCount,
      double correctionFactor,
      double groupingFactor,
      int parallelConductors,
      bool isSingleCore,
      List<String> reasoning,
      String label) async {
    for (var size in standardSizes) {
      final iz = await _getIz(
          size, insulation, standardCode, conductorCount, isSingleCore);
      final adjustedIz =
          iz * correctionFactor * groupingFactor * parallelConductors;
      if (adjustedIz >= current) {
        reasoning.add(
            '[Critical] [$label 결과] 허용전류(${adjustedIz.toStringAsFixed(1)}A) >= 필요전류(${current.toStringAsFixed(1)}A) 만족 -> 최소 굵기: ${size}mm²');
        return size;
      }
    }
    return standardSizes.last;
  }

  Future<double> _selectCableForOverload(
      int breakerRating,
      List<double> standardSizes,
      String insulation,
      String standardCode,
      int conductorCount,
      double correctionFactor,
      double groupingFactor,
      int parallelConductors,
      bool isSingleCore,
      List<String> reasoning) async {
    for (var size in standardSizes) {
      final iz = await _getIz(
          size, insulation, standardCode, conductorCount, isSingleCore);
      final adjustedIz =
          iz * correctionFactor * groupingFactor * parallelConductors;
      if (adjustedIz >= breakerRating) {
        reasoning.add(
            '[Critical] [S_CB 결과] $parallelConductors가닥 병렬 시 보정된 허용전류(${adjustedIz.toStringAsFixed(1)}A) >= 차단기(${breakerRating}A) 만족 -> 최소 굵기: ${size}mm²');
        return size;
      }
    }
    return standardSizes.last;
  }

  Future<double> _checkVoltageDrop(
      CalculationInput input,
      double ib,
      double initialSize,
      List<double> standardSizes,
      int parallelConductors,
      List<String> reasoning) async {
    final powerFactor = input.powerFactor;
    int startIndex = standardSizes.indexOf(initialSize);
    if (startIndex < 0) startIndex = 0;
    for (int i = startIndex; i < standardSizes.length; i++) {
      final currentSize = standardSizes[i];
      final specs = await _cableRepository.getCableSpecs(currentSize);
      final r = await _getResistance(currentSize, input.conductorType);
      final x = (specs?['x'] as num?)?.toDouble() ?? 0;
      final sinTheta = sqrt(1 - pow(powerFactor, 2));
      final rParallel = r / parallelConductors;
      final xParallel = x / parallelConductors;
      final double voltageDrop = (input.wiringMethod == '3상')
          ? sqrt(3) *
              ib *
              (input.cableLength / 1000) *
              (rParallel * powerFactor + xParallel * sinTheta)
          : 2 *
              ib *
              (input.cableLength / 1000) *
              (rParallel * powerFactor + xParallel * sinTheta);
      final double voltageDropPercent = (voltageDrop / input.voltage) * 100;

      // KEC 232.3.9 Dynamic Limit
      // Note: CalculationInput likely needs updates to carry checking conditions,
      // but safely defaulting to 3% logic if we don't have extra inputs,
      // OR we can infer from 'isMotor' -> Other Load (5%).
      // For now, let's keep it safe (3%) OR improve if input has flags.
      // Assuming Input doesn't have checks yet, let's stick to strict or check logic.
      // Wait, user asked to ADD features.
      // I should update CalculationInput first? Or just use strict for auto-selection.
      // For auto-selection (Menu 2), 3% (Low/Light) is the safest 'Design Basis'.
      // If we want to relax, we need user input.
      // For now, let's keep _allowedVoltageDropPercent for Menu 2 (Cable Size)
      // UNLESS we update CalculationInput.
      // Let's use the strict 3% for automatic selection to be safe.

      if (voltageDropPercent <= _allowedVoltageDropPercent) {
        reasoning.add(
            '[Critical] [Step 3] 전압강하 검토(${currentSize}mm²): ${voltageDropPercent.toStringAsFixed(2)}% (<= $_allowedVoltageDropPercent%) -> 통과');
        return currentSize;
      }
    }
    reasoning.add('[경고] 전압강하 기준 만족 불가 (최대규격 선정)');
    return standardSizes.last;
  }

  Future<double> _checkMotorStart(
      double ib,
      double motorMultiplier,
      List<double> standardSizes,
      String insulation,
      String standardCode,
      int conductorCount,
      double correctionFactor,
      double groupingFactor,
      int parallelConductors,
      bool isSingleCore, // 파라미터 추가
      List<String> reasoning) async {
    final requiredCurrent = ib * motorMultiplier;
    reasoning.add(
        '[Step 4] 전동기 부하 검토 (기동배수: $motorMultiplier): 필요한 전류(${requiredCurrent.toStringAsFixed(2)}A) 이상을 만족해야 합니다.');
    for (var size in standardSizes) {
      final iz = await _getIz(
          size, insulation, standardCode, conductorCount, isSingleCore);
      final adjustedIz =
          iz * correctionFactor * groupingFactor * parallelConductors;
      if (adjustedIz >= requiredCurrent) {
        reasoning.add(
            '[상세 계산] └ [S_MSTH 결과] 보정 허용전류(${adjustedIz.toStringAsFixed(1)}A) >= 필요전류(${requiredCurrent.toStringAsFixed(2)}A) -> 최소 굵기: ${size}mm²');
        return size;
      }
    }
    return standardSizes.last;
  }

  Future<double> _checkVoltageDropForMotorStart(
      CalculationInput input,
      double startingCurrent,
      double initialSize,
      List<double> standardSizes,
      int parallelConductors,
      List<String> reasoning) async {
    const powerFactor = 0.4;
    const allowedDropPercent = 15.0;
    int startIndex = standardSizes.indexOf(initialSize);
    if (startIndex < 0) startIndex = 0;
    for (int i = startIndex; i < standardSizes.length; i++) {
      final currentSize = standardSizes[i];
      final specs = await _cableRepository.getCableSpecs(currentSize);
      final r = await _getResistance(currentSize, input.conductorType);
      final x = (specs?['x'] as num?)?.toDouble() ?? 0;
      final sinTheta = sqrt(1 - pow(powerFactor, 2));
      final rParallel = r / parallelConductors;
      final xParallel = x / parallelConductors;
      final double voltageDrop = (input.wiringMethod == '3상')
          ? sqrt(3) *
              startingCurrent *
              (input.cableLength / 1000) *
              (rParallel * powerFactor + xParallel * sinTheta)
          : 2 *
              startingCurrent *
              (input.cableLength / 1000) *
              (rParallel * powerFactor + xParallel * sinTheta);
      final double voltageDropPercent = (voltageDrop / input.voltage) * 100;
      if (voltageDropPercent <= allowedDropPercent) {
        reasoning.add(
            '[S_MSVD% 결과] 기동 전압강하 ${voltageDropPercent.toStringAsFixed(2)}% (규격 ${currentSize}mm²) <= 15% 만족 -> 최소 굵기: ${currentSize}mm²');
        return currentSize;
      }
    }
    reasoning.add('[S_MSVD% 결과] 기동 전압강하 만족 규격 없음 (최대 규격 선정)');
    return standardSizes.last;
  }

  Future<double> _getResistance(double cableSize, String conductorType) async {
    final specs = await _cableRepository.getCableSpecs(cableSize);
    final rMap = specs?['r'] as Map<String, dynamic>? ?? {};
    return (rMap[conductorType] as num?)?.toDouble() ??
        (rMap['구리'] as num?)?.toDouble() ??
        0;
  }

  double _calculateDesignCurrent(
      CalculationInput input, List<String> reasoning) {
    final powerInWatts = input.loadCapacity * 1000;
    final powerFactor = (input.capacityUnit == 'kVA') ? 1.0 : input.powerFactor;
    final double ib = (input.wiringMethod == '3상')
        ? powerInWatts / (sqrt(3) * input.voltage * powerFactor)
        : powerInWatts / (input.voltage * powerFactor);
    reasoning.add('[Step 1] 설계전류(IB) 계산: ${ib.toStringAsFixed(2)} A');
    return ib;
  }

  int _selectBreaker(
      double ib, List<int> standardBreakers, List<String> reasoning) {
    final breaker = standardBreakers.firstWhere((r) => r >= ib,
        orElse: () => standardBreakers.last);
    reasoning.add(
        '[Step 2.1] 차단기 선정: ${breaker}A (설계전류 ${ib.toStringAsFixed(2)}A 대비)');
    return breaker;
  }

  Future<double> _getIz(double cableSize, String insulation,
      String standardCode, int conductorCount, bool isSingleCore) async {
    final specs = await _cableRepository.getCableSpecs(cableSize);
    final izMap = specs?['iz'] as Map<String, dynamic>? ?? {};
    final insulationMap = izMap[insulation] as Map<String, dynamic>? ?? {};
    String targetCode = standardCode;
    if (isSingleCore && standardCode == 'E') {
      targetCode = 'F';
    }
    var methodMap = insulationMap[targetCode] as Map<String, dynamic>? ?? {};
    var val = (methodMap[conductorCount.toString()] as num?)?.toDouble();
    if (val == null && targetCode == 'F' && standardCode == 'E') {
      methodMap = insulationMap['E'] as Map<String, dynamic>? ?? {};
      val = (methodMap[conductorCount.toString()] as num?)?.toDouble();
    }
    return val ?? 0;
  }

  String _getGroupKeyByStandardCode(String code) {
    if (['A1', 'A2', 'B1', 'B2'].contains(code)) return 'Embedded';
    if (code == 'C') return 'Surface';
    if (code == 'D1') return 'GroundDuct';
    if (code == 'D2') return 'GroundDirect';
    return 'Tray';
  }

  double _getKFactor(String insulation, int ambientTemp) {
    // 상세 매프를 먼저 시도(초기 도체 온도 기준)하고, 값이 없으면
    // 단순 매프 값으로 대체하며, 최후의 수단으로 안전한 기본값을 사용합니다.
    try {
      final detailed = kCableMaterialCoefficientsDetailed[insulation];
      if (detailed != null && detailed.isNotEmpty) {
        final temps = detailed.keys.toList()..sort();
        // 가장 가까운 온도 키 찾기
        int nearest = temps.first;
        for (var t in temps) {
          if ((t - ambientTemp).abs() < (nearest - ambientTemp).abs()) {
            nearest = t;
          }
        }
        return detailed[nearest]!;
      }
    } catch (_) {}

    return kCableMaterialCoefficients[insulation] ?? 143.0;
  }
}

class LegacyConduitCalculationResult {
  final List<LegacyConduitRecommendation> recommendations;
  final String? expertTip;
  final double totalWireArea;
  LegacyConduitCalculationResult({
    required this.recommendations,
    this.expertTip,
    this.totalWireArea = 0.0,
  });
}

class LegacyConduitRecommendation {
  final String typeLabel;
  final int size;
  final double innerArea;
  final double occupancyRate;
  final bool isSafe;
  final String note;
  final int? disallowedSize;
  final double? disallowedOccupancy;
  LegacyConduitRecommendation(
      {required this.isSafe,
      this.note = '',
      this.typeLabel = '',
      this.size = 0,
      this.innerArea = 0,
      this.occupancyRate = 0,
      this.disallowedSize,
      this.disallowedOccupancy});
}
