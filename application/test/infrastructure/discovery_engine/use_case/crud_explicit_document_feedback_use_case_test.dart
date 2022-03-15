import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import 'crud_explicit_document_feedback_use_case_test.mocks.dart';

@GenerateMocks([HiveExplicitDocumentFeedbackRepository])
void main() {
  const uid = UniqueId.fromTrustedString('id');
  late MockHiveExplicitDocumentFeedbackRepository
      explicitDocumentFeedbackRepository;

  setUp(() {
    explicitDocumentFeedbackRepository =
        MockHiveExplicitDocumentFeedbackRepository();
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
            userReaction: UserReaction.positive,
          ),
        );
      },
      input: [
        DbCrudIn.store(
          ExplicitDocumentFeedback(
            id: uid,
            userReaction: UserReaction.positive,
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
            userReaction: UserReaction.positive,
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
            userReaction: UserReaction.positive,
          ),
        );
        when(explicitDocumentFeedbackRepository.watch(id: anyNamed('id')))
            .thenAnswer(
          (_) => Stream.value(
            ChangedEvent(
              id: uid,
              newObject: ExplicitDocumentFeedback(
                id: uid,
                userReaction: UserReaction.negative,
              ),
            ),
          ),
        );
      },
      input: [
        const DbCrudIn.watch(
          uid,
        )
      ],
      verify: (useCase) {
        verify(explicitDocumentFeedbackRepository.watch(id: uid));
      },
      expect: [
        useCaseSuccess(
          ExplicitDocumentFeedback(
            id: uid,
            userReaction: UserReaction.positive,
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
        const DbCrudIn.remove(
          uid,
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
