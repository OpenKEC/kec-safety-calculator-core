import 'package:kec_safety_calculator_core/src/models/calculation_input.dart';
import 'package:kec_safety_calculator_core/src/models/calculation_result.dart';
import 'package:kec_safety_calculator_core/src/services/kec_calculator_service.dart';

class CalculateCableSizeUseCase {
  final KecCalculatorService _service;

  CalculateCableSizeUseCase(this._service);

  Future<CalculationResult> execute(CalculationInput input) async {
    return _service.calculate(input);
  }
}
