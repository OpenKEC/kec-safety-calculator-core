import 'dart:math';
import 'common/constants.dart';
import 'common/enums.dart';

import 'cable/cable_models.dart';
import 'cable/cable_capacity_calculator.dart';

import 'voltage_drop/voltage_drop_model.dart';
import 'voltage_drop/voltage_drop_calculator.dart';

import 'protection/protection_models.dart';
import 'protection/breaker_calculator.dart';

import 'integrated_models.dart';

/// KEC ?듯빀 怨꾩궛 ?쒕퉬??(Integrated Service)
class IntegratedKecService {
  /// ?꾩껜 怨꾩궛 ?섑뻾
  static Future<KecCalculationResult> calculate(KecCalculationInput input) async {
    final reasoning = <String>[];

    // 1. 湲곕낯 ?뺣낫 濡쒓퉭
    reasoning.add(
        '[湲곕낯] ${input.wiringMethod}, ${input.voltage}V, ${input.loadCapacity}${input.capacityUnit}, '
        'L=${input.cableLength}m, ${input.insulationType}, ${input.conductorType}, ${input.constructionMethodCode}');
    
    // -- Step 1 & 2: ?ㅺ퀎?꾨쪟 諛?李⑤떒湲??좎젙 --
    final dcParams = DesignCurrentParams(
      capacity: input.loadCapacity,
      capacityUnit: input.capacityUnit,
      systemVoltage: input.voltage,
      wiringType: input.wiringMethod,
      powerFactor: input.powerFactor,
      isMotorLoad: input.isMotor,
      motorStartingMultiplier: input.motorStartingMultiplier,
    );

    int breaker = 0;
    double ib = 0;

    if (input.isBreakerMode) {
      breaker = input.inputBreakerA ?? 0;
      ib = 0; 
      reasoning.add('[Step 1~2] 李⑤떒湲??곗꽑 紐⑤뱶: ${breaker}A ?좎젙 (?ㅺ퀎?꾨쪟 ?앸왂)');
    } else {
      final breakerResult = BreakerCalculator.selectBreaker(
        params: dcParams,
        breakerType: input.breakerType,
      );
      ib = breakerResult.designCurrent;
      breaker = breakerResult.selectedBreakerRating;
      reasoning.add('[Step 1] ?ㅺ퀎?꾨쪟(Ib): ${ib.toStringAsFixed(2)}A');
      reasoning.add('[Step 2] 李⑤떒湲??좎젙(In): ${breaker}A');
    }

    // -- Step 3: ?덉슜?꾨쪟 湲곗? 耳?대툝 ?좎젙 (S_B, S_CB) --
    final baseCableParams = CableCapacityParams(
      insulationType: input.insulationType,
      conductorType: input.conductorType,
      constructionCode: input.constructionMethodCode,
      ambientTemperature: input.ambientTemperature,
      numberOfCircuits: input.numberOfCircuits,
      conductorCount: (input.wiringMethod == WiringType.singlePhase) ? 2 : 3,
      parallelConductors: input.parallelConductors,
      isSingleCore: input.isSingleCore,
    );

    // 3.1 S_B (?ㅺ퀎?꾨쪟 湲곗? 理쒖냼 援듦린)
    double cableForIb = 0;
    if (!input.isBreakerMode) {
      final resIb = CableCapacityCalculator.selectMinCableSize(
        targetCurrent: ib,
        params: baseCableParams,
      );
      cableForIb = resIb.cableSizeSq;
      reasoning.add(
          '[Step 3.1] ?ㅺ퀎?꾨쪟 湲곗?(S_B): ${cableForIb}mm짼 (?덉슜?꾨쪟 ${resIb.adjustedIz.toStringAsFixed(1)}A >= ${ib.toStringAsFixed(1)}A)');
    }

    // 3.2 S_CB (李⑤떒湲??뺢꺽 湲곗? 理쒖냼 援듦린 -> 怨쇰???蹂댄샇)
    final resCb = CableCapacityCalculator.selectMinCableSize(
      targetCurrent: breaker.toDouble(),
      params: baseCableParams,
    );
    final cableForBreaker = resCb.cableSizeSq;
    reasoning.add(
        '[Step 3.2] 李⑤떒湲?湲곗?(S_CB): ${cableForBreaker}mm짼 (?덉슜?꾨쪟 ${resCb.adjustedIz.toStringAsFixed(1)}A >= ${breaker}A)');

    // -- Step 5: ?꾩븬媛뺥븯 寃??--
    final currentForVd = input.isBreakerMode ? breaker.toDouble() : ib;
    
    double cableForVoltageDrop = 0;
    final maxAllowedDrop = 3.0; // 3%

    for (final size in kStandardCableSizes) {
      if (size < cableForBreaker) continue;

      final vdParams = VoltageDropParams(
        lengthInMeters: input.cableLength,
        loadCurrent: currentForVd,
        cableSizeSq: size,
        systemVoltage: input.voltage,
        wiringType: input.wiringMethod,
        powerFactor: input.powerFactor,
        conductorType: input.conductorType,
        parallelConductors: input.parallelConductors,
      );
      
      final vdResult = VoltageDropCalculator.calculate(vdParams);
      if (vdResult.dropPercent <= maxAllowedDrop) {
        cableForVoltageDrop = size;
        reasoning.add(
            '[Step 5] ?꾩븬媛뺥븯 寃??S_VD): ${size}mm짼 (${vdResult.dropPercent.toStringAsFixed(2)}% <= $maxAllowedDrop%)');
        break;
      }
    }

    // Step 6: ?꾨룞湲?湲곕룞 諛??⑤씫?꾨쪟 寃??
    double cableForMotorThermal = 0;
    double cableForMotorVoltageDrop = 0;

    if (input.isMotor) {
      final startingMultiplier = input.motorStartingMultiplier ?? 1.25;
      final startingCurrent = ib * startingMultiplier;

      // S_MSTH
      final resForMotorStart = CableCapacityCalculator.selectMinCableSize(
        targetCurrent: startingCurrent,
        params: baseCableParams,
      );
      cableForMotorThermal = resForMotorStart.cableSizeSq;
      reasoning.add(
          '[Step 6.1] 湲곕룞 ?댁쟻 ?대젰(S_MSTH): ${cableForMotorThermal}mm짼 (?덉슜?꾨쪟 ${resForMotorStart.adjustedIz.toStringAsFixed(1)}A >= 湲곕룞?꾨쪟 ${startingCurrent.toStringAsFixed(1)}A)');

      // S_MSVD% (湲곕룞 ???꾩븬媛뺥븯 15% ?대궡)
      for (final size in kStandardCableSizes) {
        if (size < cableForMotorThermal) continue;

        final vdParams = VoltageDropParams(
          lengthInMeters: input.cableLength,
          loadCurrent: startingCurrent,
          cableSizeSq: size,
          systemVoltage: input.voltage,
          wiringType: input.wiringMethod,
          powerFactor: 0.4, 
          conductorType: input.conductorType,
          parallelConductors: input.parallelConductors,
        );

        final vdResult = VoltageDropCalculator.calculate(vdParams);
        if (vdResult.dropPercent <= 15.0) {
          cableForMotorVoltageDrop = size;
          reasoning.add(
              '[Step 6.2] 湲곕룞 ?꾩븬媛뺥븯(S_MSVD): ${size}mm짼 (${vdResult.dropPercent.toStringAsFixed(2)}% <= 15% 留뚯”)');
          break;
        }
      }
    }

    double cableForShortCircuit = 0;
    double rawMinSizeForShortCircuit = 0;
    double kFactor = 143.0;
    double? reducedKA;

    if (input.shortCircuitCurrent != null &&
        input.shortCircuitDuration != null) {
      
      double currentMaxSq = [
        cableForIb,
        cableForBreaker,
        cableForVoltageDrop,
        cableForMotorThermal,
        cableForMotorVoltageDrop
      ].reduce(max);
      if (currentMaxSq == 0) currentMaxSq = 1.5; 

      reducedKA = BreakerCalculator.calculateReducedShortCircuitCurrent(
        startKA: input.shortCircuitCurrent!,
        length: input.cableLength,
        sq: currentMaxSq
      );
      
      final scParams = ShortCircuitParams(
        shortCircuitCurrentKa: reducedKA, 
        durationSeconds: input.shortCircuitDuration!,
        insulationType: input.insulationType,
      );

      final scResult =
          BreakerCalculator.checkShortCircuitSafety(params: scParams);
      rawMinSizeForShortCircuit = scResult.minCableSizeSq;
      kFactor = scResult.kFactor;

      reasoning.add('[Step 6.3] ?⑤씫?꾨쪟 寃??S_SC): ?낅젰 ${input.shortCircuitCurrent}kA -> 留먮떒 ${reducedKA.toStringAsFixed(2)}kA (媛먯뇙?곸슜)');

      for (final size in kStandardCableSizes) {
        if (size >= rawMinSizeForShortCircuit) {
          cableForShortCircuit = size;
          reasoning.add(
              '  ??理쒖냼援듦린 ${rawMinSizeForShortCircuit.toStringAsFixed(2)}mm짼 ?鍮?-> ?좎젙: ${size}mm짼');
          break;
        }
      }
    }

    // 理쒖쥌 援듦린 ?좎젙
    final finalCableSize = [
      cableForIb,
      cableForBreaker,
      cableForVoltageDrop,
      cableForMotorThermal,
      cableForMotorVoltageDrop,
      cableForShortCircuit
    ].reduce(max);

    reasoning.add(
        '[Step 6] 理쒖쥌 援듦린 ?좎젙: 紐⑤뱺 議곌굔??留뚯”?섎뒗 理쒕? 援듦린 ${finalCableSize}mm짼瑜?理쒖쥌 ?좎젙?⑸땲??');

    return KecCalculationResult(
      finalCableSize: finalCableSize,
      finalBreakerRating: breaker,
      reasoning: reasoning,
      shortCircuitCurrent: input.shortCircuitCurrent ?? 0.0,
      shortCircuitDuration: input.shortCircuitDuration ?? 0.0,
      minCableSizeForShortCircuit: rawMinSizeForShortCircuit,
      kFactor: kFactor,
      reducedShortCircuitCurrent: reducedKA,
      detailResults: {
        'S_B (?ㅺ퀎?꾨쪟)': cableForIb,
        'S_CB (李⑤떒湲?': cableForBreaker,
        'S_VD% (?꾩븬媛뺥븯)': cableForVoltageDrop,
        'S_SC (?⑤씫媛뺣룄)': cableForShortCircuit > 0 ? cableForShortCircuit : 'N/A',
        'S_MSTH (湲곕룞?댁쟻)': input.isMotor ? cableForMotorThermal : 'N/A',
        'S_MSVD% (湲곕룞?꾩븬)': input.isMotor ? cableForMotorVoltageDrop : 'N/A',
      },
    );
  }
}
