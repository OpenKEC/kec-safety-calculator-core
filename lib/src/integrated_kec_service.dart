import 'dart:math';

import 'common/constants.dart';
import 'common/enums.dart';
import 'integrated_models.dart';
import 'cable/cable_capacity_calculator.dart';
import 'cable/cable_models.dart';
import 'voltage_drop/voltage_drop_calculator.dart';
import 'voltage_drop/voltage_drop_model.dart';
import 'protection/breaker_calculator.dart';
import 'protection/protection_models.dart';

/// KEC 6단계 통합 계산 프로세스를 수행하는 서비스
class IntegratedKecService {
  static const double _allowedVoltageDropPercent = 3.0;

  /// 통합 계산 실행
  static Future<KecCalculationResult> calculate(
      KecCalculationInput input) async {
    final reasoning = <String>[];

    reasoning.add(
        '[기본 조건] 도체:${input.conductorType.name}, 절연체:${input.insulationType.name}, 보호장치:${input.breakerType.name}, 병렬도체수:${input.parallelConductors}가닥, 회로수:${input.numberOfCircuits}');

    // Step 1: 설계전류 (Ib) 계산
    final breakerParams = DesignCurrentParams(
      capacity: input.loadCapacity,
      capacityUnit: input.capacityUnit,
      systemVoltage: input.voltage,
      wiringType: input.wiringMethod,
      powerFactor: input.powerFactor,
      isMotorLoad: input.isMotor,
      motorStartingMultiplier: input.motorStartingMultiplier,
    );

    final breakerSelection = BreakerCalculator.selectBreaker(
      params: breakerParams,
      breakerType: input.breakerType,
    );

    final ib = breakerSelection.designCurrent;
    final targetBreakerCurrent = breakerSelection.targetCurrent;
    final breaker = breakerSelection.selectedBreakerRating;

    reasoning.add('[Step 1] 설계전류(Ib) 계산: ${ib.toStringAsFixed(2)} A');
    if (input.isMotor) {
      reasoning.add(
          '[Step 2.0] 전동기 부하 여유율 적용: ${targetBreakerCurrent.toStringAsFixed(2)} A 기준 차단기 선정');
    }
    reasoning.add('[Step 2.1] 차단기 선정: $breaker A 선정');

    // 공사방법 데이터 조회
    final constructionMethod = kConstructionMethods.firstWhere(
      (m) => m.code == input.constructionMethodCode,
      orElse: () => kConstructionMethods.first,
    );

    // Step 3: 설계전류 기준 굵기 (S_B)
    final baseCableParams = CableCapacityParams(
      cableSizeSq: 1.5, // Dummy
      insulationType: input.insulationType,
      conductorType: input.conductorType,
      constructionCode: constructionMethod.standardCode,
      ambientTemperature: input.ambientTemperature,
      numberOfCircuits: input.numberOfCircuits,
      conductorCount: (input.wiringMethod == WiringType.singlePhase) ? 2 : 3,
      parallelConductors: input.parallelConductors,
    );

    final resForIb = CableCapacityCalculator.selectMinCableSize(
      targetCurrent: ib,
      params: baseCableParams,
    );
    final cableForIb = resForIb.cableSizeSq;
    reasoning.add(
        '[Step 3] 설계전류 기준(S_B) 결과: ${cableForIb}mm² (허용전류 ${resForIb.adjustedIz.toStringAsFixed(1)}A >= Ib ${ib.toStringAsFixed(1)}A)');

    // Step 4: 차단기 기준 굵기 (S_CB)
    final resForBreaker = CableCapacityCalculator.selectMinCableSize(
      targetCurrent: breaker.toDouble(),
      params: baseCableParams,
    );
    final cableForBreaker = resForBreaker.cableSizeSq;
    reasoning.add(
        '[Step 4] 차단기 정격 기준(S_CB) 결과: ${cableForBreaker}mm² (허용전류 ${resForBreaker.adjustedIz.toStringAsFixed(1)}A >= In ${breaker}A)');

    // Step 5: 전압강하 검토 (S_VD%)
    double cableForVoltageDrop = cableForBreaker;
    for (final size in kStandardCableSizes) {
      if (size < cableForBreaker) continue;

      final vdParams = VoltageDropParams(
        lengthInMeters: input.cableLength,
        loadCurrent: ib,
        cableSizeSq: size,
        systemVoltage: input.voltage,
        wiringType: input.wiringMethod,
        powerFactor: input.powerFactor,
        conductorType: input.conductorType,
        parallelConductors: input.parallelConductors,
      );

      final vdResult = VoltageDropCalculator.calculate(vdParams);
      if (vdResult.dropPercent <= _allowedVoltageDropPercent) {
        cableForVoltageDrop = size;
        reasoning.add(
            '[Step 5] 전압강하 검토(${size}mm²): ${vdResult.dropPercent.toStringAsFixed(2)}% <= $_allowedVoltageDropPercent% 만족');
        break;
      } else {
        reasoning.add(
            '[Step 5] 전압강하 검토(${size}mm²): ${vdResult.dropPercent.toStringAsFixed(2)}% 초과 -> 규격 상향');
      }
    }

    // Step 6: 전동기 기동 및 단락전류 검토
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
          '[Step 6.1] 기동 열적 내력(S_MSTH): ${cableForMotorThermal}mm² (허용전류 ${resForMotorStart.adjustedIz.toStringAsFixed(1)}A >= 기동전류 ${startingCurrent.toStringAsFixed(1)}A)');

      // S_MSVD% (기동 시 전압강하 15% 이내)
      for (final size in kStandardCableSizes) {
        if (size < cableForMotorThermal) continue;

        final vdParams = VoltageDropParams(
          lengthInMeters: input.cableLength,
          loadCurrent: startingCurrent,
          cableSizeSq: size,
          systemVoltage: input.voltage,
          wiringType: input.wiringMethod,
          powerFactor: 0.4, // 기동 시 역률 0.4 가정 (Original Logic)
          conductorType: input.conductorType,
          parallelConductors: input.parallelConductors,
        );

        final vdResult = VoltageDropCalculator.calculate(vdParams);
        if (vdResult.dropPercent <= 15.0) {
          cableForMotorVoltageDrop = size;
          reasoning.add(
              '[Step 6.2] 기동 전압강하(S_MSVD): ${size}mm² (${vdResult.dropPercent.toStringAsFixed(2)}% <= 15% 만족)');
          break;
        }
      }
    }

    double cableForShortCircuit = 0;
    double rawMinSizeForShortCircuit = 0;
    double kFactor = 143.0;

    if (input.shortCircuitCurrent != null &&
        input.shortCircuitDuration != null) {
      final scParams = ShortCircuitParams(
        shortCircuitCurrentKa: input.shortCircuitCurrent!,
        durationSeconds: input.shortCircuitDuration!,
        insulationType: input.insulationType,
      );

      final scResult =
          BreakerCalculator.checkShortCircuitSafety(params: scParams);
      rawMinSizeForShortCircuit = scResult.minCableSizeSq;
      kFactor = scResult.kFactor;

      for (final size in kStandardCableSizes) {
        if (size >= rawMinSizeForShortCircuit) {
          cableForShortCircuit = size;
          reasoning.add(
              '[Step 6.3] 단락전류 내력(S_SC): ${size}mm² (최소굵기 ${rawMinSizeForShortCircuit.toStringAsFixed(2)}mm² 대비 적합)');
          break;
        }
      }
    }

    // 최종 굵기 선정
    final finalCableSize = [
      cableForIb,
      cableForBreaker,
      cableForVoltageDrop,
      cableForMotorThermal,
      cableForMotorVoltageDrop,
      cableForShortCircuit
    ].reduce(max);

    reasoning.add(
        '[Step 6] 최종 굵기 선정: 모든 조건을 만족하는 최대 굵기 ${finalCableSize}mm²를 최종 선정합니다.');

    return KecCalculationResult(
      finalCableSize: finalCableSize,
      finalBreakerRating: breaker,
      reasoning: reasoning,
      shortCircuitCurrent: input.shortCircuitCurrent ?? 0.0,
      shortCircuitDuration: input.shortCircuitDuration ?? 0.0,
      minCableSizeForShortCircuit: rawMinSizeForShortCircuit,
      kFactor: kFactor,
      detailResults: {
        'S_B (설계전류)': cableForIb,
        'S_CB (차단기)': cableForBreaker,
        'S_VD% (전압강하)': cableForVoltageDrop,
        'S_SC (단락강도)': cableForShortCircuit > 0 ? cableForShortCircuit : 'N/A',
        'S_MSTH (기동열적)': input.isMotor ? cableForMotorThermal : 'N/A',
        'S_MSVD% (기동전압)': input.isMotor ? cableForMotorVoltageDrop : 'N/A',
      },
    );
  }
}
