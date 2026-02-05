class ConvertResult {
  final String unit;
  final double value;
  final String? description; // For AWG or text-based results

  ConvertResult(this.unit, this.value, {this.description});
}

class ConvertUnitUseCase {
  static const Map<String, Map<String, double>> _rates = {
    '길이': {
      'mm': 1.0,
      'cm': 10.0,
      'm': 1000.0,
      'km': 1000000.0,
      'inch': 25.4,
      'ft': 304.8,
      'yd': 914.4,
      'mile': 1609344.0,
    },
    '넓이': {
      'm²': 1.0,
      'ft²': 0.092903,
      '평': 3.3058,
    },
    '무게': {
      'g': 0.001,
      'kg': 1.0,
      'oz': 0.0283495,
      'lb': 0.453592,
      '근': 0.6,
    },
    '부피': {
      'cc': 0.001,
      'mL': 0.001,
      'L': 1.0,
      'gal': 3.78541,
      'bbl': 158.987,
    },
    '속도': {
      'm/s': 1.0,
      'km/h': 0.277778,
      'knot': 0.514444,
      'mph': 0.44704,
    },
    '마력': {
      'HP': 1.0,
      'kW': 1.34102,
    },
    '토크': {
      'N·m': 1.0,
      'kgf·m': 9.80665,
    }
  };

  static const Map<String, String> _awgMap = {
    '16': '1.5',
    '14': '2.5',
    '12': '4.0',
    '10': '6.0',
    '8': '10',
    '6': '16',
    '4': '25',
    '2': '35',
    '1': '50',
    '1/0': '50',
    '2/0': '70',
    '3/0': '95',
    '4/0': '120'
  };

  List<ConvertResult> execute({
    required String category,
    required String fromUnit,
    required double inputValue,
  }) {
    List<ConvertResult> results = [];

    if (category == '온도') {
      double c;
      // Normalize to Celsius
      if (fromUnit == '°C') {
        c = inputValue;
      } else if (fromUnit == '°F') {
        c = (inputValue - 32) * 5 / 9;
      } else if (fromUnit == 'K') {
        c = inputValue - 273.15;
      } else {
        c = inputValue;
      }

      results.add(ConvertResult('°C', c));
      results.add(ConvertResult('°F', (c * 9 / 5) + 32));
      results.add(ConvertResult('K', c + 273.15));
      return results;
    }

    if (category == '전선(AWG)') {
      _awgMap.forEach((awg, sq) {
        results.add(ConvertResult('$sq SQ', 0, description: 'AWG $awg'));
      });
      return results;
    }

    final categoryRates = _rates[category];
    if (categoryRates != null) {
      final baseRate = categoryRates[fromUnit] ?? 1.0;
      final standardValue =
          inputValue * baseRate; // value in base unit (e.g. mm)

      categoryRates.forEach((unit, rate) {
        results.add(ConvertResult(unit, standardValue / rate));
      });
    }

    return results;
  }

  // Helper to get allowed units
  List<String> getUnits(String category) {
    if (category == '온도') {
      return ['°C', '°F', 'K'];
    }
    if (category == '전선(AWG)') {
      return ['AWG'];
    }
    return _rates[category]?.keys.toList() ?? [];
  }
}
