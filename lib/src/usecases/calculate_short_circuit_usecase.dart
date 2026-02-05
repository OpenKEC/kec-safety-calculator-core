class ShortCircuitResult {
  final double ratedCurrent;
  final double sourceScCurrent;
  final double motorScCurrent;
  final double totalScCurrent;
  final double resultKa;
  final double safetyMarginKa;
  final double? selectedBreakerKa;
  final bool isSafe;

  ShortCircuitResult({
    required this.ratedCurrent,
    required this.sourceScCurrent,
    required this.motorScCurrent,
    required this.totalScCurrent,
    required this.resultKa,
    required this.safetyMarginKa,
    required this.selectedBreakerKa,
    required this.isSafe,
  });
}

class CalculateShortCircuitUseCase {
  static const double _sqrt3 = 1.73205080757;
  static const double _motorContribMult = 4.0;
  static const double _motorEff = 0.85;
  static const double _motorPf = 0.80;
  static const double _breakerSafetyMargin = 1.2; // 20%

  static const List<double> _standardBreakerKa = [
    2.5,
    5.0,
    10.0,
    14.0,
    18.0,
    22.0,
    25.0,
    30.0,
    35.0,
    42.0,
    50.0,
    65.0,
    85.0,
    100.0
  ];

  ShortCircuitResult? execute({
    required double transformerKva,
    required double voltage,
    required double impedancePercent,
    required double motorLoad,
    required String motorLoadUnit, // 'kW' or 'kVA'
    required bool isThreePhase,
  }) {
    if (transformerKva <= 0 || voltage <= 0 || impedancePercent <= 0) {
      return null;
    }

    // 1. Calculate Rated Current (In)
    // In = P / (sqrt(3) * V) or P / V
    double iRated;
    if (isThreePhase) {
      iRated = (transformerKva * 1000) / (_sqrt3 * voltage);
    } else {
      iRated = (transformerKva * 1000) / voltage;
    }

    // 2. Calculate Source Short Circuit Current (Is_source)
    // Is = In * (100 / %Z)
    double iScSource = iRated * (100 / impedancePercent);

    // 3. Calculate Motor Contribution
    double iMotorFlc = 0.0;
    if (motorLoad > 0) {
      if (motorLoadUnit == 'kW') {
        if (isThreePhase) {
          iMotorFlc =
              (motorLoad * 1000) / (_sqrt3 * voltage * _motorPf * _motorEff);
        } else {
          iMotorFlc = (motorLoad * 1000) / (voltage * _motorPf * _motorEff);
        }
      } else {
        // kVA
        if (isThreePhase) {
          iMotorFlc = (motorLoad * 1000) / (_sqrt3 * voltage);
        } else {
          iMotorFlc = (motorLoad * 1000) / voltage;
        }
      }
    }
    double iMotorContrib = iMotorFlc * _motorContribMult;

    // 4. Total Short Circuit Current
    double iTotalSc = iScSource + iMotorContrib;
    double resultKa = iTotalSc / 1000;

    // 5. Breaker Selection
    double safetyMarginKa = resultKa * _breakerSafetyMargin;
    double? selectedBreaker;
    try {
      selectedBreaker =
          _standardBreakerKa.firstWhere((ka) => ka >= safetyMarginKa);
    } catch (_) {
      selectedBreaker = null; // Exceeds max standard
    }

    // Safety Check (Example: if no breaker found, it's unsafe/beyond scope)
    // But currently logical "Safe" means we found a breaker.
    bool isSafe = selectedBreaker != null;

    return ShortCircuitResult(
      ratedCurrent: iRated,
      sourceScCurrent: iScSource,
      motorScCurrent: iMotorContrib,
      totalScCurrent: iTotalSc,
      resultKa: resultKa,
      safetyMarginKa: safetyMarginKa,
      selectedBreakerKa: selectedBreaker,
      isSafe: isSafe,
    );
  }
}
