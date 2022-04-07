import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_document_time_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

import '../../../test_utils/utils.dart';

void main() {
  late MockAppDiscoveryEngine engine;

  setUp(() async {
    engine = MockAppDiscoveryEngine();
  });

  void _setUpSuccess() => when(engine.logDocumentTime(
              documentId: anyNamed('documentId'),
              mode: anyNamed('mode'),
              seconds: anyNamed('seconds')))
          .thenAnswer(
        (_) => Future.value(const ClientEventSucceeded()),
      );

  void _setUpFailure() => when(engine.logDocumentTime(
              documentId: anyNamed('documentId'),
              mode: anyNamed('mode'),
              seconds: anyNamed('seconds')))
          .thenAnswer(
        (_) => Future.value(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse)),
      );

  group('Log document time', () {
    useCaseTest(
      'WHEN logging time THEN expect a ClientEventSucceeded ',
      setUp: () => _setUpSuccess(),
      build: () => LogDocumentTimeUseCase(engine),
      input: [
        LogData(
          documentId: DocumentId(),
          mode: DocumentViewMode.story,
          duration: const Duration(seconds: 2),
        )
      ],
      expect: [useCaseSuccess(const ClientEventSucceeded())],
    );

    useCaseTest(
      'WHEN logging time and something went wrong THEN expect a EngineExceptionRaised ',
      setUp: () => _setUpFailure(),
      build: () => LogDocumentTimeUseCase(engine),
      input: [
        LogData(
          documentId: DocumentId(),
          mode: DocumentViewMode.story,
          duration: const Duration(seconds: 2),
        )
      ],
      expect: [
        useCaseSuccess(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse))
      ],
    );
  });
}
