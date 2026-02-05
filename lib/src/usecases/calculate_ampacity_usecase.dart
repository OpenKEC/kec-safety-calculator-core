import 'package:kec_safety_calculator_core/src/data/sources/static_cable_data.dart';

class AmpacityResult {
  final double nominalCurrent;
  final double tempFactor;
  final double groupFactor;
  final double soilFactor;
  final double correctedAmpacity;
  final String formula;

  AmpacityResult({
    required this.nominalCurrent,
    required this.tempFactor,
    required this.groupFactor,
    required this.soilFactor,
    required this.correctedAmpacity,
    required this.formula,
  });
}

class CalculateAmpacityUseCase {
  /// Calculates the allowable current (Ampacity) based on KEC standards.
  ///
  /// [cableSize]: Cable cross-sectional area in sqmm.
  /// [conductorType]: '구리' or '알루미늄'.
  /// [insulationType]: 'XLPE' or 'PVC'.
  /// [standardCode]: Construction method code (e.g., 'A1', 'C', 'D1').
  /// [isThreePhase]: True for 3-phase, false for Single-phase.
  /// [ambientTemp]: Ambient temperature in Celsius.
  /// [circuits]: Number of circuits for grouping factor.
  /// [installationType]: '기중' (Air) or '지중' (Earth/Ground).
  /// [soilThermalRes]: Soil thermal resistance (only for Earth). Default 2.5.
  /// [neutralHarmonic]: Whether to apply reduction for harmonic currents (0.86).
  AmpacityResult? execute({
    required double cableSize,
    required String conductorType,
    required String insulationType,
    required String standardCode,
    required bool isThreePhase,
    required double ambientTemp,
    required int circuits,
    required String installationType,
    double soilThermalRes = 2.5,
    bool neutralHarmonic = false,
  }) {
    // 1. Nominal Ampacity Lookup
    final spec = kCableSpecs[cableSize];
    if (spec == null) return null;

    final izKey = conductorType == '알루미늄' ? 'iz_al' : 'iz';
    final izData = spec[izKey] as Map<String, dynamic>?;
    final insulationData = izData?[insulationType] as Map<String, dynamic>?;

    if (insulationData == null) return null;

    final methodData = insulationData[standardCode] as Map<String, dynamic>?;

    // KEC data keys: '2' for Single Phase, '3' for Three Phase
    final wireKey = isThreePhase ? '3' : '2';
    final num? nominalCurrentNum = methodData?[wireKey];

    if (nominalCurrentNum == null) return null;
    final double nominalCurrent = nominalCurrentNum.toDouble();

    // 2. Temperature Correction Factor
    String env = installationType == '지중' ? 'Ground' : 'Air';

    // Safety check for lookup
    final tempMap = kTempCorrectionFactors[insulationType];
    final envMap = tempMap?[env];
    double tempFactor = 1.0;

    if (envMap != null) {
      // Round temp to nearest 5
      // Logic from legacy code: (temp / 5).round() * 5
      int roundedTemp = (ambientTemp / 5).round() * 5;
      tempFactor = envMap[roundedTemp] ?? 1.0;
    }

    // 3. Grouping Correction Factor
    String groupKey = ['E', 'F', 'G'].contains(standardCode)
        ? 'Tray'
        : (standardCode == 'C'
            ? 'Surface'
            : (standardCode == 'D1'
                ? 'GroundDuct'
                : (standardCode == 'D2' ? 'GroundDirect' : 'Embedded')));

    final groupMap = kGroupingCorrectionFactors[groupKey];
    double groupFactor = 1.0;
    if (groupMap != null) {
      // If circuits exceed map keys, use the last value (conservative approach)
      groupFactor = groupMap[circuits] ?? (groupMap.values.last);
    }

    // 4. Soil Thermal Correction (Only for Ground)
    double soilFactor = 1.0;
    if (installationType == '지중') {
      // Legacy logic: Round to nearest 0.5
      double key = (soilThermalRes * 2).round() / 2;
      if (key < 0.5) key = 0.5;
      if (key > 3.0) key = 3.0;
      soilFactor = kSoilThermalCorrectionFactors[key] ?? 1.0;
    }

    // 5. Final Calculation
    double harmonicFactor = neutralHarmonic ? 0.86 : 1.0;

    double result =
        nominalCurrent * tempFactor * groupFactor * soilFactor * harmonicFactor;

    String formula = '$nominalCurrent x $tempFactor x $groupFactor';
    if (installationType == '지중') formula += ' x $soilFactor';
    if (neutralHarmonic) formula += ' x 0.86 (Harmonic)';

    return AmpacityResult(
      nominalCurrent: nominalCurrent,
      tempFactor: tempFactor,
      groupFactor: groupFactor,
      soilFactor: soilFactor,
      correctedAmpacity: result,
      formula: formula,
    );
  }
}
