
/// 공사방법의 정보를 담는 데이터 클래스
class ConstructionMethod {
  final String code; // 번호 (예: "1", "2")
  final String description; // 설치 방법 설명
  final String standardCode; // 적용하는 표준 공사 방법 코드 (예: "A1", "B2")
  final String imagePath; // [추가] 이미지가 저장된 경로
  final List<String> allowedCableTypes; // [New] 'single', 'multi'
  final String installationType; // [New] 'Air' or 'Earth'

  const ConstructionMethod({
    required this.code,
    required this.description,
    required this.standardCode,
    required this.imagePath,
    this.allowedCableTypes = const ['single', 'multi'], // Default to both
    this.installationType = 'Air', // Default to Air
  });
}

