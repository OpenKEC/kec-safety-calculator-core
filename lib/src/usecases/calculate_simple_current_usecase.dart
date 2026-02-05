class CalculateSimpleCurrentUseCase {
  double execute({
    required double voltage,
    required double powerKw,
    required bool isThreePhase,
  }) {
    if (voltage == 0) return 0.0;

    if (isThreePhase) {
      return (powerKw * 1000) / (voltage * 1.7320508);
    } else {
      return (powerKw * 1000) / voltage;
    }
  }
}
