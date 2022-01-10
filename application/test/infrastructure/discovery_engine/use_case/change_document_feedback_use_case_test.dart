import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

import '../../../presentation/utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;

  setUp(() async {
    engine = MockDiscoveryEngine();
  });

  void _setUpSuccess() => when(engine.changeDocumentFeedback(
              documentId: anyNamed('documentId'),
              feedback: anyNamed('feedback')))
          .thenAnswer(
        (_) => Future.value(const ClientEventSucceeded()),
      );

  void _setUpFailure() => when(engine.changeDocumentFeedback(
              documentId: anyNamed('documentId'),
              feedback: anyNamed('feedback')))
          .thenAnswer(
        (_) => Future.value(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse)),
      );

  group('Change document feedback', () {
    useCaseTest(
      'WHEN changing feedback THEN expect a ClientEventSucceeded ',
      setUp: () => _setUpSuccess(),
      build: () => ChangeDocumentFeedbackUseCase(engine),
      input: [
        DocumentFeedbackChange(
          documentId: DocumentId(),
          feedback: DocumentFeedback.positive,
        )
      ],
      expect: [useCaseSuccess(const ClientEventSucceeded())],
    );

    useCaseTest(
      'WHEN changing feedback and the document is unmatched THEN expect a EngineExceptionRaised ',
      setUp: () => _setUpFailure(),
      build: () => ChangeDocumentFeedbackUseCase(engine),
      input: [
        DocumentFeedbackChange(
          documentId: DocumentId(),
          feedback: DocumentFeedback.positive,
        )
      ],
      expect: [
        useCaseSuccess(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse))
      ],
    );
  });
}
