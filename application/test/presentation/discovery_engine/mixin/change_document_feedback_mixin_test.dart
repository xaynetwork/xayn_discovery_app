import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/crud_out.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../test_utils/fakes.dart';
import '../../test_utils/utils.dart';
import 'change_document_feedback_mixin_test.mocks.dart';

@GenerateMocks([
  AnalyticsService,
  CrudExplicitDocumentFeedbackUseCase,
])
void main() {
  late MockAppDiscoveryEngine engine;
  late MockAnalyticsService analyticsService;
  late MockCrudExplicitDocumentFeedbackUseCase
      crudExplicitDocumentFeedbackUseCase;
  final controller = StreamController<EngineEvent>.broadcast();

  setUp(() async {
    engine = MockAppDiscoveryEngine();
    analyticsService = MockAnalyticsService();
    crudExplicitDocumentFeedbackUseCase =
        MockCrudExplicitDocumentFeedbackUseCase();

    di.allowReassignment = true;

    di.registerSingletonAsync<EngineEventsUseCase>(
        () => Future.value(EngineEventsUseCase(engine)));
    di.registerSingletonAsync<ChangeDocumentFeedbackUseCase>(
        () => Future.value(ChangeDocumentFeedbackUseCase(engine)));
    di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(analyticsService));
    di.registerLazySingleton<CrudExplicitDocumentFeedbackUseCase>(
        () => crudExplicitDocumentFeedbackUseCase);

    when(analyticsService.send(any)).thenAnswer((_) => Future.value());

    when(engine.engineEvents).thenAnswer((_) => controller.stream);

    when(engine.changeUserReaction(
            documentId: anyNamed('documentId'),
            userReaction: anyNamed('userReaction')))
        .thenAnswer(
      (_) {
        const event = ClientEventSucceeded();

        controller.add(event);

        return Future.value(event);
      },
    );

    when(crudExplicitDocumentFeedbackUseCase.singleOutput(any))
        .thenAnswer((realInvocation) async {
      final param = realInvocation.positionalArguments.first as DbCrudIn;

      return CrudOut.single(value: ExplicitDocumentFeedback(id: param.id));
    });
  });

  blocTest<_TestBloc, bool>(
    'WHEN changing feedback THEN this is passed to the engine and finally the engine emits an engine event ',
    build: () => _TestBloc(di.get<EngineEventsUseCase>()),
    act: (bloc) => bloc.changeUserReaction(
      document: fakeDocument,
      userReaction: UserReaction.positive,
      context: FeedbackContext.explicit,
    ),
    verify: (manager) {
      verify(engine.engineEvents);
      verify(engine.changeUserReaction(
        documentId: fakeDocument.documentId,
        userReaction: UserReaction.positive,
      ));
      verifyNoMoreInteractions(engine);
    },
    expect: () => [true],
  );

  blocTest<_TestBloc, bool>(
    'WHEN changing explicit feedback THEN expect explicit document feedback ',
    build: () => _TestBloc(di.get<EngineEventsUseCase>()),
    act: (bloc) => bloc.changeUserReaction(
      document: fakeDocument,
      userReaction: UserReaction.positive,
      context: FeedbackContext.explicit,
    ),
    verify: (manager) {
      verify(
        crudExplicitDocumentFeedbackUseCase.singleOutput(
          DbCrudIn.store(
            ExplicitDocumentFeedback(
              id: fakeDocument.documentId.uniqueId,
              userReaction: UserReaction.positive,
            ),
          ),
        ),
      );
      verifyNoMoreInteractions(crudExplicitDocumentFeedbackUseCase);
    },
    expect: () => [true],
  );

  blocTest<_TestBloc, bool>(
    'WHEN changing implicit feedback THEN expect implicit document feedback ',
    build: () => _TestBloc(di.get<EngineEventsUseCase>()),
    act: (bloc) => bloc.changeUserReaction(
      document: fakeDocument,
      userReaction: UserReaction.positive,
      context: FeedbackContext.implicit,
    ),
    verify: (manager) {
      verifyNever(crudExplicitDocumentFeedbackUseCase.singleOutput(any));
      verifyNoMoreInteractions(crudExplicitDocumentFeedbackUseCase);
    },
    expect: () => [true],
  );
}

class _TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, ChangeUserReactionMixin<bool> {
  _TestBloc(this.engineEventsUseCase) : super(false);

  final EngineEventsUseCase engineEventsUseCase;

  late final UseCaseValueStream<EngineEvent> engineEvents = consume(
    engineEventsUseCase,
    initialData: none,
  );

  @override
  Future<bool?> computeState() =>
      fold(engineEvents).foldAll((events, errorReport) async => true);
}
