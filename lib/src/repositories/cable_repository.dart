
/// 케이블 및 차단기 관련 데이터를 제공하는 리포지토리의 인터페이스
abstract class CableRepository {
  /// 표준 케이블 굵기(단면적, mm^2) 리스트를 반환합니다.
  Future<List<double>> getStandardCableSizes();

  /// [수정] 차단기 종류에 맞는 표준 정격 용량(A) 리스트를 반환합니다.
  Future<List<int>> getStandardBreakerRatings(String breakerType);

  /// 특정 굵기의 케이블 사양(허용 전류, 저항, 리액턴스)을 반환합니다.
  Future<Map<String, dynamic>?> getCableSpecs(double cableSize);
}

