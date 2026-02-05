/// 계산에 필요한 입력 값들을 담는 데이터 클래스
class CalculationInput {
  final double voltage;
  final double loadCapacity;
  final String capacityUnit;
  final double cableLength;
  final String wiringMethod;
  final String conductorType;
  final String insulationType;
  final String constructionMethodCode; // 표준 공사방법 코드
  final int ambientTemperature;
  final String breakerType;
  final bool isMotor;
  final double powerFactor;
  final int numberOfCircuits;
  final int parallelConductors; // [New] 병렬도체수
  final bool isTightInstallation; // [New] 밀착 시공 여부

  final bool isSingleCore; // [New] 단심 여부

  // [New] 차단기 우선 모드 (Logic Step 1 & 2 분기용)
  final bool isBreakerMode;
  final double? inputBreakerA;

  // 고급 옵션
  final double? motorStartingMultiplier;
  final double? shortCircuitCurrent;
  final double? shortCircuitDuration;
  final double? directLoadEndShortCircuitCurrent;

  CalculationInput({
    required this.voltage,
    required this.loadCapacity,
    this.capacityUnit = 'kW',
    required this.cableLength,
    required this.wiringMethod,
    this.conductorType = '구리',
    this.insulationType = 'XLPE',
    // 표준: constructionMethodCode 필수
    required this.constructionMethodCode,
    this.ambientTemperature = 30,
    this.breakerType = '주택용',
    required this.isMotor,
    this.powerFactor = 0.9,
    this.numberOfCircuits = 1, // [신규] 기본값 1
    this.parallelConductors = 1, // [신규] 기본값 1
    this.isTightInstallation = false, // [신규] 기본값 false (이격 포설)
    // 단락전류 직접 입력 여부 (삭제됨) - 로직이 directLoadEndShortCircuitCurrent 확인으로 이동
    this.isSingleCore = false, // [신규] 기본값 false (다심)
    this.isBreakerMode = false, // [신규] 기본값 false (부하 기준)
    this.inputBreakerA,
    this.motorStartingMultiplier,
    this.shortCircuitCurrent,
    this.shortCircuitDuration,
    this.directLoadEndShortCircuitCurrent,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationInput &&
          runtimeType == other.runtimeType &&
          voltage == other.voltage &&
          loadCapacity == other.loadCapacity &&
          capacityUnit == other.capacityUnit &&
          cableLength == other.cableLength &&
          wiringMethod == other.wiringMethod &&
          conductorType == other.conductorType &&
          insulationType == other.insulationType &&
          constructionMethodCode == other.constructionMethodCode &&
          ambientTemperature == other.ambientTemperature &&
          breakerType == other.breakerType &&
          isMotor == other.isMotor &&
          powerFactor == other.powerFactor &&
          numberOfCircuits == other.numberOfCircuits &&
          parallelConductors == other.parallelConductors &&
          isTightInstallation == other.isTightInstallation &&
          isSingleCore == other.isSingleCore &&
          motorStartingMultiplier == other.motorStartingMultiplier &&
          shortCircuitCurrent == other.shortCircuitCurrent &&
          shortCircuitDuration == other.shortCircuitDuration;

  @override
  int get hashCode =>
      voltage.hashCode ^
      loadCapacity.hashCode ^
      capacityUnit.hashCode ^
      cableLength.hashCode ^
      wiringMethod.hashCode ^
      conductorType.hashCode ^
      insulationType.hashCode ^
      constructionMethodCode.hashCode ^
      ambientTemperature.hashCode ^
      breakerType.hashCode ^
      isMotor.hashCode ^
      powerFactor.hashCode ^
      numberOfCircuits.hashCode ^
      parallelConductors.hashCode ^
      isTightInstallation.hashCode ^
      isSingleCore.hashCode ^
      motorStartingMultiplier.hashCode ^
      shortCircuitCurrent.hashCode ^
      shortCircuitDuration.hashCode;
}
