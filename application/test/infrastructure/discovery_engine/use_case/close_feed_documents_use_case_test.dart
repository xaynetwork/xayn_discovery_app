import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

import '../../../presentation/test_utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;

  setUp(() async {
    engine = MockDiscoveryEngine();
  });

  void _setUpSuccess() => when(engine.closeFeedDocuments(any)).thenAnswer(
        (_) => Future.value(const ClientEventSucceeded()),
      );

  void _setUpFailure() => when(engine.closeFeedDocuments(any)).thenAnswer(
        (_) => Future.value(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse)),
      );

  group('Close feed documents', () {
    useCaseTest(
      'WHEN closing feed docs THEN expect a ClientEventSucceeded ',
      setUp: () => _setUpSuccess(),
      build: () => CloseFeedDocumentsUseCase(engine),
      input: [
        {DocumentId()}
      ],
      expect: [useCaseSuccess(const ClientEventSucceeded())],
    );

    useCaseTest(
      'WHEN closing feed docs and something went wrong THEN expect a EngineExceptionRaised ',
      setUp: () => _setUpFailure(),
      build: () => CloseFeedDocumentsUseCase(engine),
      input: [
        {DocumentId()}
      ],
      expect: [
        useCaseSuccess(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse))
      ],
    );
  });
}
