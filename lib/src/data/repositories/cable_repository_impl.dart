
import 'package:kec_safety_calculator_core/src/repositories/cable_repository.dart';
import 'package:kec_safety_calculator_core/src/data/sources/static_cable_data.dart';

class CableRepositoryImpl implements CableRepository {

  @override
  Future<List<double>> getStandardCableSizes() async {
    return kStandardCableSizes;
  }

  @override
  Future<List<int>> getStandardBreakerRatings(String breakerType) async {
    // [수정] 보호 장치 종류에 따라 다른 정격 목록을 반환합니다.
    switch (breakerType) {
      case '산업용':
        return kIndustrialBreakerRatings;
      case '퓨즈':
        return kFuseRatings;
      case '주택용':
      default:
        return kResidentialBreakerRatings;
    }
  }

  @override
  Future<Map<String, dynamic>?> getCableSpecs(double cableSize) async {
    return kCableSpecs[cableSize];
  }
}


