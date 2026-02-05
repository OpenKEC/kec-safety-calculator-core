class CalculateRpmUseCase {
  double execute({
    required double frequency,
    required int poles,
  }) {
    if (poles == 0) return 0.0;
    return (120 * frequency) / poles;
  }
}
