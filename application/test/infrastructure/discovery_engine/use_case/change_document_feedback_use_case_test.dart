import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

import '../../../test_utils/utils.dart';

void main() {
  late MockAppDiscoveryEngine engine;

  setUp(() async {
    engine = MockAppDiscoveryEngine();
  });

  void _setUpSuccess() => when(engine.changeUserReaction(
              documentId: anyNamed('documentId'),
              userReaction: anyNamed('userReaction')))
          .thenAnswer(
        (_) => Future.value(const ClientEventSucceeded()),
      );

  void _setUpFailure() => when(engine.changeUserReaction(
              documentId: anyNamed('documentId'),
              userReaction: anyNamed('userReaction')))
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
          userReaction: UserReaction.positive,
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
          userReaction: UserReaction.positive,
        )
      ],
      expect: [
        useCaseSuccess(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse))
      ],
    );
  });
}
