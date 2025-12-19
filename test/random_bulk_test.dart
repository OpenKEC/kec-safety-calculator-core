import 'dart:math';
import 'package:test/test.dart';
import 'package:kec_safety_calculator_core/kec_calculator.dart';

void main() {
  final random = Random();

  T randomElement<T>(List<T> list) => list[random.nextInt(list.length)];

  double randomDouble(double min, double max) =>
      min + random.nextDouble() * (max - min);

  int randomInt(int min, int max) => min + random.nextInt(max - min + 1);

  final standardSizes = kStandardCableSizes;
  final constructionCodes = kConstructionMethods.map((m) => m.code).toList();

  group('KEC 로직 무작위 대량 테스트 (10회씩)', () {
    test('[1] 허용전류 계산 무작위 테스트', () {
      print('\n--- [1] 허용전류 무작위 데이터 테스트 ---');
      for (int i = 1; i <= 10; i++) {
        final params = CableCapacityParams(
          cableSizeSq: randomElement(standardSizes),
          insulationType: randomElement(InsulationType.values),
          conductorType: randomElement(ConductorType.values),
          constructionCode: randomElement(
              ['A1', 'A2', 'B1', 'B2', 'C', 'D1', 'D2', 'E', 'F', 'G']),
          ambientTemperature: randomInt(15, 55),
          numberOfCircuits: randomInt(1, 9),
          conductorCount: randomElement([2, 3]),
          parallelConductors: randomInt(1, 4),
        );

        try {
          final result = CableCapacityCalculator.calculate(params);
          print(
              'Test #$i: Size:${params.cableSizeSq} / Temp:${params.ambientTemperature} / Circuits:${params.numberOfCircuits} => Iz:${result.adjustedIz.toStringAsFixed(2)}A');
        } catch (e) {
          print('Test #$i: FAILED - $e');
          fail('Error during calculation: $e');
        }
      }
    });

    test('[2] 전압강하 계산 무작위 테스트', () {
      print('\n--- [2] 전압강하 무작위 데이터 테스트 ---');
      for (int i = 1; i <= 10; i++) {
        final params = VoltageDropParams(
          lengthInMeters: randomDouble(10, 200),
          loadCurrent: randomDouble(5, 200),
          cableSizeSq: randomElement(standardSizes),
          systemVoltage: randomElement([220, 380, 440]),
          wiringType: randomElement(WiringType.values),
          powerFactor: randomDouble(0.8, 1.0),
          conductorType: randomElement(ConductorType.values),
        );

        try {
          final result = VoltageDropCalculator.calculate(params);
          print(
              'Test #$i: L:${params.lengthInMeters.toInt()}m / I:${params.loadCurrent.toInt()}A / Size:${params.cableSizeSq}sq => Drop:${result.dropPercent.toStringAsFixed(2)}%');
        } catch (e) {
          print('Test #$i: FAILED - $e');
          fail('Error during calculation: $e');
        }
      }
    });

    test('[3] 차단기 선정 무작위 테스트', () {
      print('\n--- [3] 차단기 선정 무작위 데이터 테스트 ---');
      for (int i = 1; i <= 10; i++) {
        final params = DesignCurrentParams(
          capacity: randomDouble(1, 50),
          capacityUnit: 'kW',
          systemVoltage: randomElement([220, 380, 440]),
          wiringType: randomElement(WiringType.values),
          powerFactor: randomDouble(0.8, 1.0),
          isMotorLoad: random.nextBool(),
        );

        try {
          final result = BreakerCalculator.selectBreaker(
            params: params,
            breakerType: randomElement(BreakerType.values),
          );
          print(
              'Test #$i: P:${params.capacity.toInt()}kW / Motor:${params.isMotorLoad} => Ib:${result.designCurrent.toStringAsFixed(1)}A / Breaker:${result.selectedBreakerRating}A');
        } catch (e) {
          print('Test #$i: FAILED - $e');
          fail('Error during calculation: $e');
        }
      }
    });

    test('[4] 단락전류 계산 무작위 테스트', () {
      print('\n--- [4] 단락전류 무작위 데이터 테스트 ---');
      for (int i = 1; i <= 10; i++) {
        final kva = randomDouble(100, 2500);
        final volt = randomElement([220.0, 380.0, 440.0]);
        final imp = randomDouble(4.0, 6.0);

        try {
          final result = BreakerCalculator.calculateShortCircuitCurrent(
            kva: kva,
            voltage: volt,
            impedancePercent: imp,
          );
          print(
              'Test #$i: Tr:${kva.toInt()}kVA / Volt:${volt.toInt()}V / Imp:${imp.toStringAsFixed(1)}% => Is:${result.toStringAsFixed(2)}kA');
        } catch (e) {
          print('Test #$i: FAILED - $e');
          fail('Error during calculation: $e');
        }
      }
    });

    test('[5] 접지선 굵기 무작위 테스트', () {
      print('\n--- [5] 접지선 굵기 무작위 데이터 테스트 ---');
      for (int i = 1; i <= 10; i++) {
        final params = ShortCircuitParams(
          shortCircuitCurrentKa: randomDouble(1, 40),
          durationSeconds: randomDouble(0.1, 1.0),
          insulationType: randomElement(InsulationType.values),
        );

        try {
          final result =
              BreakerCalculator.checkShortCircuitSafety(params: params);
          print(
              'Test #$i: Is:${params.shortCircuitCurrentKa.toInt()}kA / t:${params.durationSeconds.toStringAsFixed(1)}s => MinSize:${result.minCableSizeSq.toStringAsFixed(2)}sq');
        } catch (e) {
          print('Test #$i: FAILED - $e');
          fail('Error during calculation: $e');
        }
      }
    });

    test('[6] 전선관 굵기 무작위 테스트', () {
      print('\n--- [6] 전선관 굵기 무작위 데이터 테스트 ---');
      for (int i = 1; i <= 10; i++) {
        final params = ConduitParams(
          mainWireSizeSq: randomElement(standardSizes),
          mainWireCount: randomInt(2, 5),
          mainWireType: randomElement(CableCoreType.values),
          earthWireSizeSq: randomElement(standardSizes),
          earthWireCount: 1,
        );

        try {
          final result = ConduitCalculator.calculateDetailed(params);
          print(
              'Test #$i: Main:${params.mainWireSizeSq}x${params.mainWireCount} / Earth:${params.earthWireSizeSq} => TotalArea:${result.totalWireArea.toInt()}mm²');
        } catch (e) {
          print('Test #$i: FAILED - $e');
          fail('Error during calculation: $e');
        }
      }
    });

    test('[7] 통합 설계 (6단계) 무작위 테스트', () async {
      print('\n--- [7] 통합 설계 무작위 데이터 테스트 ---');
      for (int i = 1; i <= 10; i++) {
        final input = KecCalculationInput(
          voltage: randomElement([220.0, 380.0, 440.0]),
          loadCapacity: randomDouble(1, 100),
          capacityUnit: 'kW',
          cableLength: randomDouble(10, 200),
          wiringMethod: randomElement(WiringType.values),
          conductorType: ConductorType.copper,
          insulationType: InsulationType.xlpe,
          constructionMethodCode: randomElement(['A1', 'B1', 'C', 'E', 'F']),
          ambientTemperature: 30,
          breakerType: BreakerType.industrial,
          isMotor: random.nextBool(),
          powerFactor: 0.9,
          motorStartingMultiplier: 1.5,
          shortCircuitCurrent: randomDouble(1, 20),
          shortCircuitDuration: 0.1,
        );

        try {
          final result = await IntegratedKecService.calculate(input);
          print(
              'Test #$i: P:${input.loadCapacity.toInt()}kW / Motor:${input.isMotor} / L:${input.cableLength.toInt()}m => FinalSize:${result.finalCableSize}sq / Breaker:${result.finalBreakerRating}A');
        } catch (e) {
          print('Test #$i: FAILED - $input');
          print('Detail Error: $e');
          fail('Error during calculation: $e');
        }
      }
    });
  });
}
