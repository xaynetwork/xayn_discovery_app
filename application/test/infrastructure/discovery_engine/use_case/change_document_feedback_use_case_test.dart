import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

import '../../../test_utils/fakes.dart';
import '../../../test_utils/utils.dart';

void main() {
  late MockAppDiscoveryEngine engine;
  late MockDocumentRepository documentRepository;

  final documentIdFromEngine = DocumentId();
  final documentIdNotFromEngine = DocumentId();

  setUp(() async {
    engine = MockAppDiscoveryEngine();
    documentRepository = MockDocumentRepository();
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

  void _setUpDocuments() {
    when(documentRepository.getByDocumentId(documentIdFromEngine)).thenAnswer(
      (_) => DocumentWrapper(
        fakeDocument,
        isEngineDocument: true,
      ),
    );

    when(documentRepository.getByDocumentId(documentIdNotFromEngine))
        .thenAnswer(
      (_) => DocumentWrapper(
        fakeDocument,
        isEngineDocument: false,
      ),
    );
  }

  group('Change document feedback', () {
    useCaseTest(
      'WHEN changing feedback THEN expect a ClientEventSucceeded ',
      setUp: () {
        _setUpSuccess();
        _setUpDocuments();
      },
      build: () => ChangeDocumentFeedbackUseCase(engine, documentRepository),
      input: [
        DocumentFeedbackChange(
          documentId: documentIdFromEngine,
          userReaction: UserReaction.positive,
        )
      ],
      expect: [useCaseSuccess(const ClientEventSucceeded())],
    );

    useCaseTest(
      'WHEN changing feedback and the document is unmatched THEN expect a EngineExceptionRaised ',
      setUp: () {
        _setUpFailure();
        _setUpDocuments();
      },
      build: () => ChangeDocumentFeedbackUseCase(engine, documentRepository),
      input: [
        DocumentFeedbackChange(
          documentId: documentIdFromEngine,
          userReaction: UserReaction.positive,
        )
      ],
      expect: [
        useCaseSuccess(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse))
      ],
    );

    useCaseTest(
      'WHEN changing feedback AND document not from engine THEN expect no events fired',
      setUp: () {
        _setUpSuccess();
        _setUpDocuments();
      },
      build: () => ChangeDocumentFeedbackUseCase(engine, documentRepository),
      input: [
        DocumentFeedbackChange(
          documentId: documentIdNotFromEngine,
          userReaction: UserReaction.positive,
        )
      ],
      expect: [],
    );
  });
}
