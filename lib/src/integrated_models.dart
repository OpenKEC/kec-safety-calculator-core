import 'common/enums.dart';

/// ?듯빀 怨꾩궛 ?낅젰 ?뚮씪誘명꽣
class KecCalculationInput {
  final WiringType wiringMethod;
  final double voltage;
  final double loadCapacity;
  final String capacityUnit;
  final double cableLength;
  final InsulationType insulationType;
  final ConductorType conductorType;
  final String constructionMethodCode;
  final double powerFactor;
  final bool isMotor;
  final double? motorStartingMultiplier;
  final bool isBreakerMode;
  final int? inputBreakerA;
  final BreakerType breakerType;
  final int numberOfCircuits;
  final int parallelConductors;
  final bool isSingleCore;
  final double? shortCircuitCurrent;
  final double? shortCircuitDuration;

  KecCalculationInput({
    required this.wiringMethod,
    required this.voltage,
    required this.loadCapacity,
    required this.capacityUnit,
    required this.cableLength,
    required this.insulationType,
    required this.conductorType,
    required this.constructionMethodCode,
    this.powerFactor = 0.9,
    this.isMotor = false,
    this.motorStartingMultiplier,
    this.isBreakerMode = false,
    this.inputBreakerA,
    required this.breakerType,
    this.numberOfCircuits = 1,
    this.parallelConductors = 1,
    this.isSingleCore = false,
    this.shortCircuitCurrent,
    this.shortCircuitDuration,
  });
}

/// ?듯빀 怨꾩궛 寃곌낵 紐⑤뜽
class KecCalculationResult {
  final double finalCableSize;
  final int finalBreakerRating;
  final List<String> reasoning;
  final double shortCircuitCurrent;
  final double shortCircuitDuration;
  final double minCableSizeForShortCircuit;
  final double kFactor;
  final Map<String, dynamic> detailResults;
  final double? reducedShortCircuitCurrent; // [New] 遺?섎떒 ?⑤씫?꾨쪟

  KecCalculationResult({
    required this.finalCableSize,
    required this.finalBreakerRating,
    required this.reasoning,
    required this.shortCircuitCurrent,
    required this.shortCircuitDuration,
    required this.minCableSizeForShortCircuit,
    required this.kFactor,
    required this.detailResults,
    this.reducedShortCircuitCurrent,
  });
}
