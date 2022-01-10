import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/reset_engine_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

import '../../../presentation/utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;

  setUp(() async {
    engine = MockDiscoveryEngine();
  });

  void _setUpSuccess() => when(engine.resetEngine()).thenAnswer(
        (_) => Future.value(const ClientEventSucceeded()),
      );

  void _setUpFailure() => when(engine.resetEngine()).thenAnswer(
        (_) => Future.value(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse)),
      );

  group('Reset engine', () {
    useCaseTest(
      'WHEN resetting the engine THEN expect a ClientEventSucceeded ',
      setUp: () => _setUpSuccess(),
      build: () => ResetEngineUseCase(engine),
      input: [none],
      expect: [useCaseSuccess(const ClientEventSucceeded())],
    );

    useCaseTest(
      'WHEN resetting the engine and something went wrong THEN expect a EngineExceptionRaised ',
      setUp: () => _setUpFailure(),
      build: () => ResetEngineUseCase(engine),
      input: [none],
      expect: [
        useCaseSuccess(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse))
      ],
    );
  });
}
