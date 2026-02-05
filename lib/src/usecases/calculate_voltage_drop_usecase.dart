import 'package:kec_safety_calculator_core/src/data/sources/static_cable_data.dart';
import 'dart:math';

class VoltageDropResult {
  final double dropVoltage;
  final double dropRate;
  final String formula;
  final Map<String, dynamic> debugData;

  VoltageDropResult({
    required this.dropVoltage,
    required this.dropRate,
    required this.formula,
    required this.debugData,
  });
}

class CalculateVoltageDropUseCase {
  /// Calculates voltage drop using the detailed KEC formula:
  /// e = k * I * (R*cosθ + X*sinθ) * L
  ///
  /// [voltage]: System voltage (V) (e.g., 380, 220).
  /// [current]: Load current (A).
  /// [length]: Distance (m).
  /// [powerFactor]: Power Factor (0.0 ~ 1.0). Default 0.8.
  /// [cableSize]: Cable size (sqmm).
  /// [conductorType]: '구리' or '알루미늄'.
  /// [wiringMethod]: '단상 2선식', '단상 3선식', '3상 3선식', '3상 4선식'.
  /// [parallels]: Number of parallel conductors. Default 1.
  VoltageDropResult? executeDetailed({
    required double voltage,
    required double current,
    required double length,
    required double cableSize, // 복구
    required String conductorType,
    required String wiringMethod,
    required String insulationType,
    double powerFactor = 0.8,
    int parallels = 1,
    double temperature = 30,
  }) {
    if (current <= 0 || length <= 0) return null;

    // k factor
    double k = 1.0;
    if (wiringMethod == '단상 2선식') {
      k = 2.0;
    } else if (wiringMethod == '단상 3선식') {
      k = 1.0;
    } else if (wiringMethod.contains('3상')) {
      k = sqrt(3);
    }

    final spec = kCableSpecs[cableSize];
    if (spec == null) return null;

    final rMap = spec['r'] as Map<String, dynamic>?;
    final rValueRaw = (rMap?[conductorType] as num?)?.toDouble();
    final xValueRaw = (spec['x'] as num?)?.toDouble();

    if (rValueRaw == null || xValueRaw == null) return null;

    // 1. 온도 보정 (KEC 기준: 20도 기준 저항을 가동 온도로 변환)
    // 일반적으로 전압강하 계산 시 PVC는 70도, XLPE는 90도 기준으로 계산하거나 입력된 온도를 사용함.
    // 여기서는 사용자 입력 온도(주위온도)에 도체 발열을 고려한 보수적 접근 또는 직접 입력을 가정.
    // 일단 입력된 온도를 기준으로 보정 (향후 부하율에 따른 도체 온도 추정 로직 추가 가능)
    double alpha = conductorType == '구리' ? 0.00393 : 0.00403;
    double rCorrected = rValueRaw * (1 + alpha * (temperature - 20));

    // 2. 병렬 도체수 반영 (R_total = R_single / N, X_total = X_single / N)
    double r = (rCorrected / 1000) / parallels; // ohm/m
    double x = (xValueRaw / 1000) / parallels; // ohm/m

    double sinTheta = sqrt(max(0, 1 - pow(powerFactor, 2)));

    double drop = k * current * (r * powerFactor + x * sinTheta) * length;
    double rate = (drop / voltage) * 100;

    return VoltageDropResult(
      dropVoltage: drop,
      dropRate: rate,
      formula:
          'e = $k × $current × ($r·$powerFactor + $x·${sinTheta.toStringAsFixed(3)}) × $length',
      debugData: {
        'k': k,
        'r': r,
        'x': x,
        'sinTheta': sinTheta,
        'current': current, // 추가
      },
    );
  }

  /// Calculates voltage drop using the simplified formula (often used for quick estimation or DC).
  /// e = (35.6 * L * I) / (1000 * A * e_factor) ... (Example for Copper Single Phase)
  ///
  /// *Note*: The standard KEC method prefers the impedance method (detailed) above.
  /// This method is provided for compatibility with legacy 'Simplified' logic if needed,
  /// typically found in older 'PanelCapacityScreen' logic.
  ///
  /// However, for consistency, wrapping the detailed logic to behave 'simply' with defaults is better.
  /// FOR NOW: We will stick to the Detailed method as the primary Truth.
  /// If the legacy code used a different formula (e.g. constant K), we should migrate it to Detailed if possible.
  ///
  /// Let's look at `PanelCapacityScreen._calculateVoltageDrop`:
  /// It calls `_calculateVoltageDrop` which calls `_calculateVoltageDropSimple`.
  /// `_calculateVoltageDropSimple` seems to use a specific simplified formula.
  ///
  /// To avoid breaking changes, I will reproduce the 'Simple' logic here if necessary,
  /// OR better yet, just point everything to the Detailed logic which is more accurate.
  ///
  /// Decision: Use Detailed logic. It covers all cases better.
}
