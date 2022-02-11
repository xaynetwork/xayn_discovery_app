import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import 'crud_explicit_document_feedback_use_case_test.mocks.dart';

@GenerateMocks([ExplicitDocumentFeedbackRepository])
void main() {
  const uid = UniqueId.fromTrustedString('id');
  late MockExplicitDocumentFeedbackRepository
      explicitDocumentFeedbackRepository;

  setUp(() {
    explicitDocumentFeedbackRepository =
        MockExplicitDocumentFeedbackRepository();
  });

  group('ExplicitDocumentFeedback CRUD operations', () {
    useCaseTest(
      'WHEN crud op is save THEN repository does storage ',
      build: () => CrudExplicitDocumentFeedbackUseCase(
          explicitDocumentFeedbackRepository),
      setUp: () {
        when(explicitDocumentFeedbackRepository.save(any)).thenAnswer(
          (_) => ExplicitDocumentFeedback(
            id: uid,
            feedback: DocumentFeedback.positive,
          ),
        );
      },
      input: [
        CrudExplicitDocumentFeedbackUseCaseIn.store(
          ExplicitDocumentFeedback(
            id: uid,
            feedback: DocumentFeedback.positive,
          ),
        )
      ],
      verify: (useCase) {
        verify(explicitDocumentFeedbackRepository.save(any));
      },
      expect: [
        useCaseSuccess(
          ExplicitDocumentFeedback(
            id: uid,
            feedback: DocumentFeedback.positive,
          ),
        ),
      ],
    );

    useCaseTest(
      'WHEN crud op is watch THEN repository is observed ',
      build: () => CrudExplicitDocumentFeedbackUseCase(
          explicitDocumentFeedbackRepository),
      setUp: () {
        when(explicitDocumentFeedbackRepository.getById(any)).thenReturn(
          ExplicitDocumentFeedback(
            id: uid,
            feedback: DocumentFeedback.positive,
          ),
        );
        when(explicitDocumentFeedbackRepository.watch(id: anyNamed('id')))
            .thenAnswer(
          (_) => Stream.value(
            ChangedEvent(
              id: uid,
              newObject: ExplicitDocumentFeedback(
                id: uid,
                feedback: DocumentFeedback.negative,
              ),
            ),
          ),
        );
      },
      input: [
        CrudExplicitDocumentFeedbackUseCaseIn.watch(
          ExplicitDocumentFeedback(id: uid),
        )
      ],
      verify: (useCase) {
        verify(explicitDocumentFeedbackRepository.watch(id: uid));
      },
      expect: [
        useCaseSuccess(
          ExplicitDocumentFeedback(
            id: uid,
            feedback: DocumentFeedback.positive,
          ),
        ),
      ],
    );

    useCaseTest(
      'WHEN crud op is remove THEN entry is removed ',
      build: () => CrudExplicitDocumentFeedbackUseCase(
          explicitDocumentFeedbackRepository),
      setUp: () {
        when(
          explicitDocumentFeedbackRepository.getById(any),
        ).thenReturn(
          ExplicitDocumentFeedback(
            id: uid,
          ),
        );
        when(
          explicitDocumentFeedbackRepository.remove(any),
        ).thenAnswer(
          (_) => ExplicitDocumentFeedback(
            id: uid,
          ),
        );
      },
      input: [
        CrudExplicitDocumentFeedbackUseCaseIn.remove(
          ExplicitDocumentFeedback(id: uid),
        )
      ],
      verify: (useCase) {
        verify(
          explicitDocumentFeedbackRepository.remove(
            ExplicitDocumentFeedback(
              id: uid,
            ),
          ),
        );
      },
      expect: [
        useCaseSuccess(
          ExplicitDocumentFeedback(
            id: uid,
          ),
        ),
      ],
    );
  });
}
