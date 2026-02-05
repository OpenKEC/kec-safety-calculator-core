class CalculateEarthingUseCase {
  double execute(double s) {
    if (s <= 16) return s;
    if (s <= 35) return 16.0;
    return s / 2.0;
  }
}
