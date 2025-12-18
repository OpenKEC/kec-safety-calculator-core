import 'enums.dart';

/// 공사 방법 데이터 클래스
class ConstructionMethodData {
  final String code;
  final String description;
  final String standardCode;
  final String imagePath;
  final List<CableCoreType> allowedCableTypes;
  final InstallationType installationType;

  const ConstructionMethodData({
    required this.code,
    required this.description,
    required this.standardCode,
    required this.imagePath,
    this.allowedCableTypes = const [CableCoreType.single, CableCoreType.multi],
    this.installationType = InstallationType.air,
  });
}

// ==========================================
// 1. 공사 방법 목록 (KEC 기준)
// ==========================================
const List<ConstructionMethodData> kConstructionMethods = [
  ConstructionMethodData(
      code: '1',
      description: '단열벽 속에 매입한 전선관 내부의 절연도체 또는 단심 케이블',
      standardCode: 'A1',
      imagePath: 'assets/images/construction/1_A1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '2',
      description: '단열벽 속에 매입한 전선관 내부의 다심 케이블',
      standardCode: 'A2',
      imagePath: 'assets/images/construction/2_A2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '3',
      description: '단열벽 속에 직접 매입한 다심 케이블',
      standardCode: 'A1',
      imagePath: 'assets/images/construction/3_A1.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '4',
      description: '목재 또는 석재의 벽면에 부착한 전선관 내부의 절연도체 또는 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/4_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '5',
      description:
          '목재 또는 석재의 벽면에 부착한 전선관 안 또는 그 벽면으로부터 전선관 바깥지름의 0.3배 미만의 간격으로 배관된 전선관 안의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/5_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '6',
      description: '목재 벽면 또는 석재 벽면에 부착한 케이블 트렁킹 내의 절연도체 또는 단심 케이블 (수평 배관)',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/6_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '7',
      description: '목재 벽면 또는 석재 벽면에 부착한 케이블 트렁킹 내의 절연도체 또는 단심 케이블 (수직 배관)',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/7_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '8',
      description: '목재 벽면 또는 석재 벽면에 부착한 케이블 트렁킹 내의 다심 케이블 (수평 포설)',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/8_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '9',
      description: '목재 벽면 또는 석재 벽면에 부착한 케이블 트렁킹 내의 다심 케이블 (수직 포설)',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/9_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '10',
      description: '현수형 케이블 트렁킹 내부의 절연도체 또는 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/10_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '11',
      description: '현수형 케이블 트렁킹 내부의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/11_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '12',
      description: '몰딩 내부의 절연도체 또는 단심 케이블',
      standardCode: 'A1',
      imagePath: 'assets/images/construction/12_A1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '15',
      description: '전선관 내부의 절연도체 또는 치마도리 내부의 단심 케이블이나 다심 케이블',
      standardCode: 'A1',
      imagePath: 'assets/images/construction/15_A1.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '16',
      description: '창틀 안에 시설하는 전선관 내부의 절연도체, 단심 케이블 또는 다심 케이블',
      standardCode: 'A1',
      imagePath: 'assets/images/construction/16_A1.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '20',
      description:
          '단심 또는 다심 케이블: 목재벽 또는 석재벽에 고정 또는 벽면과 케이블지름의 0.3배 미만의 간격으로 설치된 경우',
      standardCode: 'C',
      imagePath: 'assets/images/construction/20_C.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '21',
      description: '단심 또는 다심 케이블: 목재 또는 석재 천장면에 직접 고정된 경우',
      standardCode: 'C',
      imagePath: 'assets/images/construction/21_C.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '22',
      description: '단심 또는 다심 케이블: 천장과 거리를 두고 설치된 경우 (검토 중, 방법 E 사용 가능)',
      standardCode: 'E',
      imagePath: 'assets/images/construction/22_E.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '23',
      description: '현수형 전기사용기기의 고정설비',
      standardCode: 'C',
      imagePath: 'assets/images/construction/23_C.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '30',
      description: '단심 또는 다심 케이블: 수직 또는 수평으로 설치되는 비천공형 트레이에 포설',
      standardCode: 'C',
      imagePath: 'assets/images/construction/30_C.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '31',
      description: '단심 또는 다심 케이블: 수직 또는 수평으로 설치되는 천공형 트레이에 포설',
      standardCode: 'E',
      imagePath: 'assets/images/construction/31_E.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '32',
      description: '단심 또는 다심 케이블: 수직 또는 수평으로 배치되는 케이블 브래킷 또는 와이어 메시 트레이에 포설',
      standardCode: 'E',
      imagePath: 'assets/images/construction/32_E.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '33',
      description: '단심 또는 다심 케이블: 벽과의 간격이 케이블 지름의 0.3배 이상인 경우',
      standardCode: 'E',
      imagePath: 'assets/images/construction/33_E.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '34',
      description: '단심 또는 다심 케이블: 케이블 래더에 포설',
      standardCode: 'E',
      imagePath: 'assets/images/construction/34_E.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '35',
      description: '조가용선에 매달려 있거나 조가용선과 일체화하여 묶음 배선한 단심 또는 다심 케이블',
      standardCode: 'E',
      imagePath: 'assets/images/construction/35_E.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '36',
      description: '애자지지 나도체 또는 절연도체',
      standardCode: 'G',
      imagePath: 'assets/images/construction/36_G.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '40-1',
      description: '건물 내 빈 공간의 절연도체 또는 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/40_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '40-2',
      description: '건물 내 빈 공간의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/40_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '41-1',
      description: '건물 내 빈 공간에 설치된 전선관 내의 절연도체',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/41_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '41-2',
      description: '건물 내 빈 공간에 설치된 전선관 내의 다심 케이블 (참조)',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/41_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '42-1',
      description: '건물 내 빈 공간에 설치된 전선관 내의 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/42_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '42-2',
      description: '건물 내 빈 공간에 설치된 전선관 내의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/42_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '43-1',
      description: '건물 내 빈 공간에 설치된 케이블 덕트 내의 절연 전선',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/43_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '43-2',
      description: '건물 내 빈 공간에 설치된 케이블 덕트 내의 다심 케이블 (참조)',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/43_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '44-1',
      description: '건물 내 빈 공간에 설치된 케이블 덕트의 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/44_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '44-2',
      description: '건물 내 빈 공간에 설치된 케이블 덕트의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/44_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '45-1',
      description: '열저항률이 2 K·m/W 이하인 석재 내부에 설치된 케이블 덕트 내의 절연도체',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/45_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '45-2',
      description: '열저항률이 2 K·m/W 이하인 석재 내부에 설치된 케이블 덕트 내의 다심 케이블 (참조)',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/45_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '46-1',
      description: '열저항률이 2 K·m/W 이하인 석재 내부에 설치된 케이블 덕트 내의 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/46_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '46-2',
      description: '열저항률이 2 K·m/W 이하인 석재 내부에 설치된 케이블 덕트 내의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/46_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '47-1',
      description: '이중천장 안 또는 이중바닥에 설치된 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/47_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '47-2',
      description: '이중천장 안 또는 이중바닥에 설치된 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/47_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '50',
      description: '바닥매입형 케이블 트렁킹 내부의 절연도체 또는 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/50_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '51',
      description: '바닥매입형 케이블 트렁킹 내부의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/51_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '52',
      description: '벽면매입형 케이블 트렁킹 내부의 절연도체 또는 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/52_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '53',
      description: '벽면매입형 케이블 트렁킹 내부의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/53_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '54-1',
      description: '수평/수직 비환기형 케이블 채널 내 전선관 속의 절연도체 또는 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/54_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '54-2',
      description: '수평/수직 비환기형 케이블 채널 내 전선관 속의 다심 케이블 (참조)',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/54_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '55',
      description: '바닥에 설치된 개방형 또는 환기형 케이블 채널 내 전선관 속의 절연도체',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/55_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '56',
      description: '수평 또는 수직으로 설치된 개방형 또는 환기형 케이블 채널 내 단심 또는 다심 외장 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/56_B1.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '57',
      description:
          '열저항률이 2 K·m/W 이하인 석재 내부에 직접 매설한 단심 또는 다심 케이블 (기계적 손상 보호장치 없음)',
      standardCode: 'C',
      imagePath: 'assets/images/construction/57_C.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '58',
      description:
          '열저항률이 2 K·m/W 이하인 석재 내부에 직접 매설된 단심 또는 다심 외장 케이블 (기계적 손상 보호장치 있음)',
      standardCode: 'C',
      imagePath: 'assets/images/construction/58_C.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi]),
  ConstructionMethodData(
      code: '59',
      description: '석재벽 내부에 설치된 전선관 내의 절연도체 또는 단심 케이블',
      standardCode: 'B1',
      imagePath: 'assets/images/construction/59_B1.png',
      allowedCableTypes: [CableCoreType.single]),
  ConstructionMethodData(
      code: '60',
      description: '석재 내부에 설치된 전선관 내의 다심 케이블',
      standardCode: 'B2',
      imagePath: 'assets/images/construction/60_B2.png',
      allowedCableTypes: [CableCoreType.multi]),
  ConstructionMethodData(
      code: '70',
      description: '지중 매설한 전선관 또는 케이블 덕트 내의 다심 케이블',
      standardCode: 'D1',
      imagePath: 'assets/images/construction/70_D1.png',
      allowedCableTypes: [CableCoreType.multi],
      installationType: InstallationType.ground),
  ConstructionMethodData(
      code: '71',
      description: '지중 매설한 전선관 또는 케이블 덕트 내의 단심 케이블',
      standardCode: 'D1',
      imagePath: 'assets/images/construction/71_D1.png',
      allowedCableTypes: [CableCoreType.single],
      installationType: InstallationType.ground),
  ConstructionMethodData(
      code: '72',
      description: '지중에 직접 매설한 단심 또는 다심 케이블 (기계적 추가 보호가 없는 경우)',
      standardCode: 'D2',
      imagePath: 'assets/images/construction/72_D2.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi],
      installationType: InstallationType.ground),
  ConstructionMethodData(
      code: '73',
      description: '지중에 직접 매설한 단심 또는 다심 외장 케이블 (기계적 추가 보호가 있는 경우)',
      standardCode: 'D2',
      imagePath: 'assets/images/construction/73_D2.png',
      allowedCableTypes: [CableCoreType.single, CableCoreType.multi],
      installationType: InstallationType.ground),
];

// ==========================================
// 2. 단락 전류 계산용 계수 (K-Factor)
// ==========================================
// KEC 234.5 표 234.5-1 (약식)
const Map<InsulationType, double> kCableMaterialCoefficients = {
  InsulationType.xlpe: 143,
  InsulationType.pvc: 115,
};

// ==========================================
// 3. 주위 온도 보정 계수 (Table 35)
// ==========================================
const Map<InsulationType, Map<InstallationType, Map<int, double>>>
    kTempCorrectionFactors = {
  InsulationType.pvc: {
    InstallationType.air: {
      10: 1.22,
      15: 1.17,
      20: 1.12,
      25: 1.06,
      30: 1.00,
      35: 0.94,
      40: 0.87,
      45: 0.79,
      50: 0.71,
      55: 0.61,
      60: 0.50
    },
    InstallationType.ground: {
      10: 1.10,
      15: 1.05,
      20: 1.00,
      25: 0.95,
      30: 0.89,
      35: 0.84,
      40: 0.77,
      45: 0.71,
      50: 0.63,
      55: 0.55,
      60: 0.45
    }
  },
  InsulationType.xlpe: {
    InstallationType.air: {
      10: 1.15,
      15: 1.12,
      20: 1.08,
      25: 1.04,
      30: 1.00,
      35: 0.96,
      40: 0.91,
      45: 0.87,
      50: 0.82,
      55: 0.76,
      60: 0.71,
      65: 0.65,
      70: 0.58,
      75: 0.50,
      80: 0.41
    },
    InstallationType.ground: {
      10: 1.07,
      15: 1.04,
      20: 1.00,
      25: 0.96,
      30: 0.93,
      35: 0.89,
      40: 0.85,
      45: 0.80,
      50: 0.76,
      55: 0.71,
      60: 0.65,
      65: 0.60,
      70: 0.53,
      75: 0.46,
      80: 0.38
    }
  }
};

// ==========================================
// 4. 복수 회로 보정 계수 (Table 36)
// ==========================================
const Map<String, Map<int, double>> kGroupingCorrectionFactors = {
  'Tray': {
    1: 1.00,
    2: 0.88,
    3: 0.82,
    4: 0.77,
    5: 0.75,
    6: 0.73,
    7: 0.73,
    8: 0.72,
    9: 0.72
  },
  'Embedded': {
    1: 1.00,
    2: 0.80,
    3: 0.70,
    4: 0.65,
    5: 0.60,
    6: 0.57,
    7: 0.54,
    8: 0.52,
    9: 0.50,
    12: 0.45,
    16: 0.41,
    20: 0.38
  },
  'Surface': {
    1: 1.00,
    2: 0.85,
    3: 0.79,
    4: 0.75,
    5: 0.73,
    6: 0.72,
    7: 0.72,
    8: 0.71,
    9: 0.70
  },
  'GroundDuct': {
    1: 1.00,
    2: 0.85,
    3: 0.75,
    4: 0.70,
    5: 0.65,
    6: 0.60,
    7: 0.57,
    8: 0.54,
    9: 0.52,
    10: 0.49,
    11: 0.47,
    12: 0.45
  },
  'GroundDirect': {
    1: 1.00,
    2: 0.75,
    3: 0.65,
    4: 0.60,
    5: 0.55,
    6: 0.50,
    7: 0.45,
    8: 0.43,
    9: 0.41
  }
};

// ==========================================
// 5. 표준 데이터 (규격, 정격)
// ==========================================
const List<double> kStandardCableSizes = [
  1.5,
  2.5,
  4,
  6,
  10,
  16,
  25,
  35,
  50,
  70,
  95,
  120,
  150,
  185,
  240,
  300,
  400,
  500,
  630
];

const List<int> kResidentialBreakerRatings = [
  10,
  15,
  20,
  25,
  30,
  40,
  50,
  60,
  75,
  100
];

const List<int> kIndustrialBreakerRatings = [
  15,
  20,
  30,
  40,
  50,
  60,
  75,
  100,
  125,
  150,
  175,
  200,
  225,
  250,
  300,
  350,
  400,
  500,
  600
];

const List<int> kFuseRatings = [
  10,
  16,
  20,
  25,
  32,
  40,
  50,
  63,
  80,
  100,
  125,
  160,
  200,
  250,
  315,
  400,
  500,
  630
];

const List<int> kConduitSizes = [16, 22, 28, 36, 42, 54, 70, 82, 100];

final Map<int, double> kConduitInnerDiameters = {
  16: 18.0,
  22: 22.0,
  28: 28.0,
  36: 35.0,
  42: 40.0,
  54: 51.0,
  70: 67.0,
  82: 77.0,
  100: 100.0,
};

final Map<int, double> kElpConduitInnerDiameters = {
  30: 30.0,
  40: 40.0,
  50: 50.0,
  65: 65.0,
  80: 80.0,
  100: 100.0,
  125: 125.0,
  150: 150.0,
};

final Map<int, double> kFlexibleConduitInnerDiameters = {
  16: 15.8,
  22: 20.8,
  28: 26.4,
  36: 35.0,
  42: 40.0,
  54: 51.0,
  70: 67.0,
  82: 77.0,
  100: 100.0,
};

final Map<int, double> kSteelConduitInnerDiameters = {
  16: 16.4,
  22: 21.9,
  28: 28.3,
  36: 36.9,
  42: 42.8,
  54: 55.4,
  70: 68.6,
  82: 81.3,
  92: 94.1,
  104: 106.4,
};

final Map<int, double> kCdConduitInnerDiameters = {
  16: 16.0,
  22: 22.0,
  28: 28.0,
  36: 36.0,
  42: 42.0,
  54: 54.0,
  70: 70.0,
  82: 82.0,
  100: 100.0,
};

final Map<double, double> kCableOuterDiameters = {
  1.5: 10.5,
  2.5: 11.5,
  4: 12.5,
  6: 13.5,
  10: 15.5,
  16: 17.5,
  25: 20.5,
  35: 22.5,
  50: 25.5,
  70: 28.5,
  95: 32.5,
  120: 36.0,
  150: 40.0,
  185: 44.5,
  240: 50.0,
  300: 56.0,
};

final Map<double, double> kSingleCoreCableOuterDiameters = {
  1.5: 3.4,
  2.5: 4.0,
  4: 4.8,
  6: 5.4,
  10: 6.8,
  16: 7.8,
  25: 9.8,
  35: 11.0,
  50: 13.0,
  70: 15.0,
  95: 17.5,
  120: 19.5,
  150: 21.5,
  185: 24.0,
  240: 27.5,
  300: 30.5,
};

// ==========================================
// 6. 케이블 상세 스펙 (저항, 리액턴스, 허용전류)
// ==========================================
final Map<double, Map<String, dynamic>> kCableSpecs = {
  1.5: {
    'r': {ConductorType.copper: 12.1, ConductorType.aluminum: 20.4},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 19, '3': 17},
        'A2': {'2': 18, '3': 16.5},
        'B1': {'2': 23, '3': 20},
        'B2': {'2': 22, '3': 19.5},
        'C': {'2': 25, '3': 22},
        'D1': {'2': 24, '3': 21},
        'D2': {'2': 26, '3': 23},
        'E': {'2': 26, '3': 23},
      },
      InsulationType.pvc: {
        'A1': {'2': 15.5, '3': 15.5},
        'A2': {'2': 14.5, '3': 13.5},
        'B1': {'2': 18.5, '3': 16.5},
        'B2': {'2': 17.5, '3': 16},
        'C': {'2': 20, '3': 18},
        'D1': {'2': 29, '3': 22},
        'D2': {'2': 20, '3': 18}
      }
    }
  },
  2.5: {
    'r': {ConductorType.copper: 7.41, ConductorType.aluminum: 12.1},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 26, '3': 23},
        'A2': {'2': 25, '3': 22},
        'B1': {'2': 32, '3': 28},
        'B2': {'2': 29, '3': 26},
        'C': {'2': 34, '3': 30},
        'D1': {'2': 32, '3': 28},
        'D2': {'2': 34, '3': 30},
        'E': {'2': 36, '3': 32},
      },
      InsulationType.pvc: {
        'A1': {'2': 21, '3': 20},
        'A2': {'2': 19.5, '3': 18.5},
        'B1': {'2': 25, '3': 22},
        'B2': {'2': 24, '3': 22},
        'C': {'2': 28, '3': 24},
        'D1': {'2': 39, '3': 30},
        'D2': {'2': 25, '3': 23}
      }
    }
  },
  4: {
    'r': {ConductorType.copper: 4.61, ConductorType.aluminum: 7.41},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 35, '3': 31},
        'A2': {'2': 34, '3': 30},
        'B1': {'2': 42, '3': 37},
        'B2': {'2': 40, '3': 35},
        'C': {'2': 46, '3': 40},
        'D1': {'2': 41, '3': 36},
        'D2': {'2': 44, '3': 39},
        'E': {'2': 49, '3': 42},
      },
      InsulationType.pvc: {
        'A1': {'2': 28, '3': 26},
        'A2': {'2': 25, '3': 24},
        'B1': {'2': 33, '3': 29},
        'B2': {'2': 31, '3': 28},
        'C': {'2': 37, '3': 32},
        'D1': {'2': 50, '3': 40},
        'D2': {'2': 33, '3': 29}
      }
    }
  },
  6: {
    'r': {ConductorType.copper: 3.08, ConductorType.aluminum: 4.91},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 46, '3': 40},
        'A2': {'2': 43, '3': 38},
        'B1': {'2': 55, '3': 48},
        'B2': {'2': 50, '3': 44},
        'C': {'2': 59, '3': 52},
        'D1': {'2': 50, '3': 44},
        'D2': {'2': 56, '3': 49},
        'E': {'2': 63, '3': 54},
      },
      InsulationType.pvc: {
        'A1': {'2': 36, '3': 34},
        'A2': {'2': 32, '3': 30},
        'B1': {'2': 42, '3': 37},
        'B2': {'2': 39, '3': 36},
        'C': {'2': 47, '3': 41},
        'D1': {'2': 63, '3': 51},
        'D2': {'2': 41, '3': 36}
      }
    }
  },
  10: {
    'r': {ConductorType.copper: 1.83, ConductorType.aluminum: 2.93},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 62, '3': 54},
        'A2': {'2': 58, '3': 51},
        'B1': {'2': 75, '3': 66},
        'B2': {'2': 69, '3': 60},
        'C': {'2': 81, '3': 71},
        'D1': {'2': 66, '3': 58},
        'D2': {'2': 74, '3': 65},
        'E': {'2': 86, '3': 75},
      },
      InsulationType.pvc: {
        'A1': {'2': 50, '3': 46},
        'A2': {'2': 44, '3': 41},
        'B1': {'2': 58, '3': 51},
        'B2': {'2': 53, '3': 49},
        'C': {'2': 65, '3': 56},
        'D1': {'2': 85, '3': 69},
        'D2': {'2': 57, '3': 49}
      }
    }
  },
  16: {
    'r': {ConductorType.copper: 1.15, ConductorType.aluminum: 1.83},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 83, '3': 73},
        'A2': {'2': 78, '3': 68},
        'B1': {'2': 101, '3': 88},
        'B2': {'2': 92, '3': 80},
        'C': {'2': 110, '3': 96},
        'D1': {'2': 86, '3': 75},
        'D2': {'2': 96, '3': 84},
        'E': {'2': 115, '3': 100},
      },
      InsulationType.pvc: {
        'A1': {'2': 68, '3': 61},
        'A2': {'2': 60, '3': 55},
        'B1': {'2': 77, '3': 68},
        'B2': {'2': 70, '3': 63},
        'C': {'2': 86, '3': 75},
        'D1': {'2': 112, '3': 91},
        'D2': {'2': 75, '3': 65}
      }
    }
  },
  25: {
    'r': {ConductorType.copper: 0.727, ConductorType.aluminum: 1.15},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 109, '3': 95},
        'A2': {'2': 102, '3': 89},
        'B1': {'2': 134, '3': 117},
        'B2': {'2': 120, '3': 105},
        'C': {'2': 136, '3': 119},
        'D1': {'2': 110, '3': 96},
        'D2': {'2': 123, '3': 107},
        'E': {'2': 149, '3': 127},
        'F': {'3': 161},
        'G': {'2': 182, '3': 161},
      },
      InsulationType.pvc: {
        'A1': {'2': 89, '3': 78},
        'A2': {'2': 79, '3': 71},
        'B1': {'2': 101, '3': 88},
        'B2': {'2': 92, '3': 82},
        'C': {'2': 111, '3': 96},
        'D1': {'2': 145, '3': 118},
        'D2': {'2': 96, '3': 83}
      }
    }
  },
  35: {
    'r': {ConductorType.copper: 0.524, ConductorType.aluminum: 0.868},
    'x': 0.08,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 134, '3': 117},
        'A2': {'2': 125, '3': 109},
        'B1': {'2': 165, '3': 144},
        'B2': {'2': 147, '3': 128},
        'C': {'2': 169, '3': 147},
        'D1': {'2': 132, '3': 115},
        'D2': {'2': 148, '3': 129},
        'E': {'2': 185, '3': 158},
        'F': {'3': 200},
        'G': {'2': 226, '3': 201},
      },
      InsulationType.pvc: {
        'A1': {'2': 111, '3': 98},
        'A2': {'2': 99, '3': 88},
        'B1': {'2': 125, '3': 110},
        'B2': {'2': 114, '3': 101},
        'C': {'2': 137, '3': 119},
        'D1': {'2': 177, '3': 144},
        'D2': {'2': 117, '3': 101}
      }
    }
  },
  50: {
    'r': {ConductorType.copper: 0.387, ConductorType.aluminum: 0.641},
    'x': 0.078,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 162, '3': 141},
        'A2': {'2': 149, '3': 130},
        'B1': {'2': 201, '3': 175},
        'B2': {'2': 177, '3': 154},
        'C': {'2': 205, '3': 179},
        'D1': {'2': 155, '3': 135},
        'D2': {'2': 175, '3': 153},
        'E': {'2': 225, '3': 192},
        'F': {'3': 242},
        'G': {'2': 275, '3': 246},
      },
      InsulationType.pvc: {
        'A1': {'2': 136, '3': 119},
        'A2': {'2': 118, '3': 106},
        'B1': {'2': 151, '3': 132},
        'B2': {'2': 138, '3': 121},
        'C': {'2': 165, '3': 143},
        'D1': {'2': 212, '3': 172},
        'D2': {'2': 138, '3': 119}
      }
    }
  },
  70: {
    'r': {ConductorType.copper: 0.268, ConductorType.aluminum: 0.443},
    'x': 0.078,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 205, '3': 179},
        'A2': {'2': 188, '3': 164},
        'B1': {'2': 255, '3': 222},
        'B2': {'2': 223, '3': 194},
        'C': {'2': 263, '3': 229},
        'D1': {'2': 192, '3': 167},
        'D2': {'2': 216, '3': 188},
        'E': {'2': 289, '3': 246},
        'F': {'3': 310},
        'G': {'2': 353, '3': 318},
      },
      InsulationType.pvc: {
        'A1': {'2': 173, '3': 152},
        'A2': {'2': 151, '3': 135},
        'B1': {'2': 192, '3': 168},
        'B2': {'2': 175, '3': 153},
        'C': {'2': 210, '3': 182},
        'D1': {'2': 266, '3': 215},
        'D2': {'2': 173, '3': 147}
      }
    }
  },
  95: {
    'r': {ConductorType.copper: 0.193, ConductorType.aluminum: 0.32},
    'x': 0.075,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 248, '3': 216},
        'A2': {'2': 226, '3': 197},
        'B1': {'2': 309, '3': 269},
        'B2': {'2': 267, '3': 233},
        'C': {'2': 319, '3': 278},
        'D1': {'2': 226, '3': 197},
        'D2': {'2': 259, '3': 226},
        'E': {'2': 352, '3': 298},
        'F': {'3': 377},
        'G': {'2': 430, '3': 389},
      },
      InsulationType.pvc: {
        'A1': {'2': 210, '3': 184},
        'A2': {'2': 182, '3': 163},
        'B1': {'2': 232, '3': 202},
        'B2': {'2': 210, '3': 184},
        'C': {'2': 253, '3': 219},
        'D1': {'2': 318, '3': 256},
        'D2': {'2': 205, '3': 176}
      }
    }
  },
  120: {
    'r': {ConductorType.copper: 0.153, ConductorType.aluminum: 0.253},
    'x': 0.075,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 286, '3': 249},
        'A2': {'2': 261, '3': 227},
        'B1': {'2': 358, '3': 312},
        'B2': {'2': 308, '3': 268},
        'C': {'2': 370, '3': 322},
        'D1': {'2': 256, '3': 223},
        'D2': {'2': 295, '3': 257},
        'E': {'2': 410, '3': 346},
        'F': {'3': 437},
        'G': {'2': 500, '3': 454},
      },
      InsulationType.pvc: {
        'A1': {'2': 243, '3': 213},
        'A2': {'2': 209, '3': 187},
        'B1': {'2': 268, '3': 234},
        'B2': {'2': 242, '3': 211},
        'C': {'2': 292, '3': 252},
        'E': {'2': 286, '3': 241},
        'F': {'3': 292},
        'G': {'3': 374},
        'D1': {'2': 365, '3': 294},
        'D2': {'2': 235, '3': 201}
      }
    }
  },
  150: {
    'r': {ConductorType.copper: 0.124, ConductorType.aluminum: 0.206},
    'x': 0.075,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 327, '3': 285},
        'A2': {'2': 297, '3': 259},
        'B1': {'2': 393, '3': 342},
        'B2': {'2': 345, '3': 300},
        'C': {'2': 426, '3': 371},
        'D1': {'2': 288, '3': 251},
        'D2': {'2': 330, '3': 287},
        'E': {'2': 473, '3': 399},
        'F': {'3': 504},
        'G': {'2': 577, '3': 527},
      },
      InsulationType.pvc: {
        'A1': {'2': 279, '3': 244},
        'A2': {'2': 238, '3': 211},
        'B1': {'2': 307, '3': 268},
        'B2': {'2': 276, '3': 241},
        'C': {'2': 334, '3': 288},
        'E': {'2': 316, '3': 275},
        'F': {'3': 341},
        'G': {'3': 437},
        'D1': {'2': 416, '3': 335},
        'D2': {'2': 266, '3': 228}
      }
    }
  },
  185: {
    'r': {ConductorType.copper: 0.0991, ConductorType.aluminum: 0.164},
    'x': 0.075,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 372, '3': 324},
        'A2': {'2': 339, '3': 295},
        'B1': {'2': 441, '3': 384},
        'B2': {'2': 390, '3': 340},
        'C': {'2': 487, '3': 424},
        'D1': {'2': 323, '3': 281},
        'D2': {'2': 372, '3': 324},
        'E': {'2': 542, '3': 456},
        'F': {'3': 575},
        'G': {'2': 661, '3': 605},
      },
      InsulationType.pvc: {
        'A1': {'2': 322, '3': 282},
        'A2': {'2': 272, '3': 241},
        'B1': {'2': 354, '3': 309},
        'B2': {'2': 317, '3': 277},
        'C': {'2': 384, '3': 332},
        'E': {'2': 372, '3': 314},
        'F': {'3': 386},
        'G': {'3': 494},
        'D1': {'2': 478, '3': 383},
        'D2': {'2': 303, '3': 260}
      }
    }
  },
  240: {
    'r': {ConductorType.copper: 0.0754, ConductorType.aluminum: 0.125},
    'x': 0.072,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 436, '3': 380},
        'A2': {'2': 397, '3': 346},
        'B1': {'2': 517, '3': 450},
        'B2': {'2': 457, '3': 398},
        'C': {'2': 575, '3': 500},
        'D1': {'2': 372, '3': 324},
        'D2': {'2': 431, '3': 375},
        'E': {'2': 641, '3': 538},
        'F': {'3': 679},
        'G': {'2': 781, '3': 719},
      },
      InsulationType.pvc: {
        'A1': {'2': 381, '3': 333},
        'A2': {'2': 318, '3': 282},
        'B1': {'2': 417, '3': 363},
        'B2': {'2': 373, '3': 326},
        'C': {'2': 452, '3': 391},
        'E': {'2': 439, '3': 370},
        'F': {'3': 457},
        'G': {'3': 585},
        'D1': {'2': 559, '3': 447},
        'D2': {'2': 356, '3': 304}
      }
    }
  },
  300: {
    'r': {ConductorType.copper: 0.0601, ConductorType.aluminum: 0.1},
    'x': 0.072,
    'iz': {
      InsulationType.xlpe: {
        'A1': {'2': 500, '3': 435},
        'A2': {'2': 455, '3': 396},
        'B1': {'2': 591, '3': 514},
        'B2': {'2': 523, '3': 455},
        'C': {'2': 662, '3': 576},
        'D1': {'2': 419, '3': 365},
        'D2': {'2': 481, '3': 419},
        'E': {'2': 741, '3': 621},
        'F': {'3': 783},
        'G': {'2': 902, '3': 833},
      },
      InsulationType.pvc: {
        'A1': {'2': 442, '3': 387},
        'A2': {'2': 367, '3': 325},
        'B1': {'2': 484, '3': 421},
        'B2': {'2': 433, '3': 378},
        'C': {'2': 524, '3': 453},
        'E': {'2': 509, '3': 429},
        'F': {'3': 530},
        'G': {'3': 679},
        'D1': {'2': 644, '3': 514},
        'D2': {'2': 411, '3': 351}
      }
    }
  },
  400: {
    'r': {ConductorType.copper: 0.047, ConductorType.aluminum: 0.0778},
    'x': 0.072,
    'iz': {
      InsulationType.xlpe: {
        'F': {'3': 940},
        'G': {'2': 1085, '3': 1008},
        'D2': {'2': 578, '3': 493},
      },
      InsulationType.pvc: {
        'D2': {'2': 484, '3': 413}
      }
    }
  },
  500: {
    'r': {ConductorType.copper: 0.0366, ConductorType.aluminum: 0.0605},
    'x': 0.07,
    'iz': {
      InsulationType.xlpe: {
        'F': {'3': 1083},
        'G': {'2': 1253, '3': 1169},
        'D2': {'2': 668, '3': 570},
      },
      InsulationType.pvc: {
        'D2': {'2': 558, '3': 477}
      }
    }
  },
  630: {
    'r': {ConductorType.copper: 0.0283, ConductorType.aluminum: 0.0469},
    'x': 0.07,
    'iz': {
      InsulationType.xlpe: {
        'F': {'3': 1254},
        'G': {'2': 1454, '3': 1362},
        'D2': {'2': 780, '3': 665},
      },
      InsulationType.pvc: {
        'D2': {'2': 648, '3': 553}
      }
    }
  }
};
