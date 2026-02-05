library kec_safety_calculator_core;

// Constants
export 'src/constants/disclaimer_constants.dart';
export 'src/constants/reference_constants.dart';

// Data Sources (and Repositories)
export 'src/data/sources/static_cable_data.dart';
export 'src/data/repositories/cable_repository_impl.dart';

// Repositories (Interface)
export 'src/repositories/cable_repository.dart';

// Services
export 'src/services/kec_calculator_service.dart';

// Models
export 'src/models/calculation_input.dart';
export 'src/models/calculation_result.dart';
export 'src/models/construction_method.dart';

// UseCases
export 'src/usecases/calculate_ampacity_usecase.dart';
export 'src/usecases/calculate_cable_size_usecase.dart';
export 'src/usecases/calculate_conduit_usecase.dart';
export 'src/usecases/calculate_earthing_usecase.dart';
export 'src/usecases/calculate_rpm_usecase.dart';
export 'src/usecases/calculate_short_circuit_usecase.dart';
export 'src/usecases/calculate_simple_current_usecase.dart';
export 'src/usecases/calculate_voltage_drop_usecase.dart';
export 'src/usecases/convert_unit_usecase.dart';
