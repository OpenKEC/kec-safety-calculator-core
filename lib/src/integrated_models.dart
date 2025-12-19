import 'common/enums.dart';

/// 통합 계산에 필요한 입력 값들을 담는 데이터 클래스
class KecCalculationInput {
  final double voltage;
  final double loadCapacity;
  final String capacityUnit; // 'kW' or 'kVA'
  final double cableLength;
  final WiringType wiringMethod;
  final ConductorType conductorType;
  final InsulationType insulationType;
  final String constructionMethodCode;
  final int ambientTemperature;
  final BreakerType breakerType;
  final bool isMotor;
  final double powerFactor;
  final int numberOfCircuits;
  final int parallelConductors;

  // 고급 옵션 (선택적)
  final double? motorStartingMultiplier;
  final double? shortCircuitCurrent;
  final double? shortCircuitDuration;

  KecCalculationInput({
    required this.voltage,
    required this.loadCapacity,
    this.capacityUnit = 'kW',
    required this.cableLength,
    required this.wiringMethod,
    this.conductorType = ConductorType.copper,
    this.insulationType = InsulationType.xlpe,
    required this.constructionMethodCode,
    this.ambientTemperature = 30,
    this.breakerType = BreakerType.industrial,
    required this.isMotor,
    this.powerFactor = 0.9,
    this.numberOfCircuits = 1,
    this.parallelConductors = 1,
    this.motorStartingMultiplier,
    this.shortCircuitCurrent,
    this.shortCircuitDuration,
  });
}

/// 통합 계산 결과 모델
class KecCalculationResult {
  final double finalCableSize;
  final int finalBreakerRating;
  final List<String> reasoning;
  final Map<String, dynamic> detailResults;

  // 단락전류 검토 관련 상세 정보 (UI 표시용)
  final double shortCircuitCurrent;
  final double shortCircuitDuration;
  final double minCableSizeForShortCircuit;
  final double kFactor;

  KecCalculationResult({
    required this.finalCableSize,
    required this.finalBreakerRating,
    required this.reasoning,
    required this.detailResults,
    required this.shortCircuitCurrent,
    required this.shortCircuitDuration,
    required this.minCableSizeForShortCircuit,
    required this.kFactor,
  });
}
