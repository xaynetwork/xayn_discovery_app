import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_document_feedback_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/engine_events_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../test_utils/fakes.dart';
import '../../test_utils/utils.dart';
import 'change_document_feedback_mixin_test.mocks.dart';

@GenerateMocks([AnalyticsService])
void main() {
  late MockDiscoveryEngine engine;
  late MockAnalyticsService analyticsService;
  final controller = StreamController<EngineEvent>();

  setUp(() async {
    engine = MockDiscoveryEngine();
    analyticsService = MockAnalyticsService();

    di.registerSingletonAsync<EngineEventsUseCase>(
        () => Future.value(EngineEventsUseCase(engine)));
    di.registerSingletonAsync<ChangeDocumentFeedbackUseCase>(
        () => Future.value(ChangeDocumentFeedbackUseCase(engine)));
    di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(analyticsService));

    when(analyticsService.send(any)).thenAnswer((_) => Future.value());

    when(engine.engineEvents).thenAnswer((_) => controller.stream);

    when(engine.changeDocumentFeedback(
            documentId: anyNamed('documentId'), feedback: anyNamed('feedback')))
        .thenAnswer(
      (_) {
        const event = ClientEventSucceeded();

        controller.add(event);

        return Future.value(event);
      },
    );
  });

  blocTest<_TestBloc, bool>(
    'WHEN changing feedback THEN this is passed to the engine and finally the engine emits an engine event ',
    build: () => _TestBloc(),
    act: (bloc) => bloc.changeDocumentFeedback(
      document: fakeDocument,
      feedback: DocumentFeedback.positive,
      context: FeedbackContext.explicit,
    ),
    verify: (manager) {
      verify(engine.engineEvents);
      verify(engine.changeDocumentFeedback(
        documentId: fakeDocument.documentId,
        feedback: DocumentFeedback.positive,
      ));
      verifyNoMoreInteractions(engine);
    },
    expect: () => [true],
  );
}

class _TestBloc extends Cubit<bool>
    with
        UseCaseBlocHelper<bool>,
        EngineEventsMixin<bool>,
        ChangeDocumentFeedbackMixin<bool> {
  _TestBloc() : super(false);

  @override
  Future<bool?> computeState() =>
      fold(engineEvents).foldAll((events, errorReport) async => true);
}
