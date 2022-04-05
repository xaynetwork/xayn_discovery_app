import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/crud_out.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/close_feed_documents_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockAppDiscoveryEngine engine;
  late MockCrudExplicitDocumentFeedbackUseCase
      crudExplicitDocumentFeedbackUseCase;
  final documents = {DocumentId()};

  setUp(() async {
    engine = MockAppDiscoveryEngine();
    crudExplicitDocumentFeedbackUseCase =
        MockCrudExplicitDocumentFeedbackUseCase();

    di.allowReassignment = true;

    di.registerSingletonAsync<CloseFeedDocumentsUseCase>(
        () => Future.value(CloseFeedDocumentsUseCase(engine)));
    di.registerLazySingleton<CrudExplicitDocumentFeedbackUseCase>(
        () => crudExplicitDocumentFeedbackUseCase);

    when(engine.closeFeedDocuments(any)).thenAnswer(
      (_) => Future.value(const ClientEventSucceeded()),
    );

    when(crudExplicitDocumentFeedbackUseCase.call(any))
        .thenAnswer((realInvocation) async {
      final param = realInvocation.positionalArguments.first as DbCrudIn;

      return Future.value([
        UseCaseResult.success(
            CrudOut.single(value: ExplicitDocumentFeedback(id: param.id)))
      ]);
    });
  });

  blocTest<_TestBloc, bool>(
    'WHEN closing feed documents THEN this job is passed to the engine',
    build: () => _TestBloc(),
    act: (bloc) => bloc.closeFeedDocuments(documents),
    verify: (manager) {
      expect(manager.state, equals(false));
      verify(engine.closeFeedDocuments(documents));
      verifyNoMoreInteractions(engine);
    },
  );

  blocTest<_TestBloc, bool>(
    'WHEN closing feed documents THEN explicit feedback is cleaned up',
    build: () => _TestBloc(),
    act: (bloc) => bloc.closeFeedDocuments(documents),
    verify: (manager) {
      verifyInOrder(
        documents
            .map((it) => it.uniqueId)
            .map(DbCrudIn.remove)
            .map(crudExplicitDocumentFeedbackUseCase)
            .toList(),
      );
      verifyNoMoreInteractions(crudExplicitDocumentFeedbackUseCase);
    },
  );
}

class _TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, CloseFeedDocumentsMixin<bool> {
  _TestBloc() : super(false);
}
