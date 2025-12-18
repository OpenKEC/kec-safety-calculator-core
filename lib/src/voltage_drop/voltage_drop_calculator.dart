import 'dart:math';
import '../common/constants.dart';
import '../common/enums.dart';
import 'voltage_drop_model.dart';

/// 전압강하 계산기 (Pure Dart)
class VoltageDropCalculator {
  /// 전압강하 계산 (KEC 232.3.1 근사식)
  ///
  /// [공식]
  /// 단상 2선식: e = 2 * I * L * (R' * cosθ + X' * sinθ) / 1000
  /// 3상 3선식: e = √3 * I * L * (R' * cosθ + X' * sinθ) / 1000
  /// (여기서 R', X'는 병렬도체 수가 고려된 합성 저항/리액턴스)
  static VoltageDropResult calculate(VoltageDropParams params) {
    // 1. 임피던스(R, X) 조회
    double r = params.resistancePerKm ??
        _getResistance(params.cableSizeSq, params.conductorType);
    double x = params.reactancePerKm ?? _getReactance(params.cableSizeSq);

    // 2. 병렬 도체 고려 (R/N, X/N)
    if (params.parallelConductors > 1) {
      r = r / params.parallelConductors;
      x = x / params.parallelConductors;
    }

    // 3. Sin Θ 계산
    // Power factor (cosθ) -> sinθ = sqrt(1 - cos^2θ)
    final double sinTheta = sqrt(1 - pow(params.powerFactor, 2));

    // 4. 전압강하 (V) 계산 (길이 단위 m -> 나누기 1000하여 km 단위 적용)
    final double lengthKm = params.lengthInMeters / 1000.0;

    // (R cosθ + X sinθ)
    final double impedanceTerm = (r * params.powerFactor) + (x * sinTheta);

    double voltageDrop;
    if (params.wiringType == WiringType.threePhase) {
      // 3상: √3 * I * L * Z
      voltageDrop = sqrt(3) * params.loadCurrent * lengthKm * impedanceTerm;
    } else {
      // 단상: 2 * I * L * Z
      voltageDrop = 2 * params.loadCurrent * lengthKm * impedanceTerm;
    }

    // 5. 전압강하율 (%)
    double dropPercent = 0.0;
    if (params.systemVoltage > 0) {
      dropPercent = (voltageDrop / params.systemVoltage) * 100.0;
    }

    return VoltageDropResult(
      dropVoltage: voltageDrop,
      dropPercent: dropPercent,
      usedResistance: r,
      usedReactance: x,
    );
  }

  // --- Internal Helper Methods ---

  /// 도체 저항 (R) 조회 (Ohm/km)
  static double _getResistance(double size, ConductorType type) {
    final spec = kCableSpecs[size];
    if (spec == null) return 0.0;

    final rMap = spec['r'] as Map<ConductorType, double>?;
    if (rMap == null) return 0.0;

    return rMap[type] ?? 0.0;
  }

  /// 도체 리액턴스 (X) 조회 (Ohm/km)
  static double _getReactance(double size) {
    final spec = kCableSpecs[size];
    if (spec == null) return 0.0;

    // x는 도체 재질 무관하게 일정 (일반적으로)
    return (spec['x'] as num?)?.toDouble() ?? 0.0;
  }
}
