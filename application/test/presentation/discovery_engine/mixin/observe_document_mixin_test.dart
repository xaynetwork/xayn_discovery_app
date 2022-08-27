import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_document_time_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_card_observation_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/singleton_subscription_observer.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockAppDiscoveryEngine engine;
  late MockAnalyticsService analyticsService;
  late MockMarketingAnalyticsService marketingAnalyticsService;
  late MockDocumentRepository documentRepository;
  final document = Document(
    documentId: DocumentId(),
    userReaction: UserReaction.neutral,
    resource: NewsResource(
      title: '',
      snippet: '',
      url: Uri.base,
      sourceDomain: Source('example'),
      image: Uri.base,
      datePublished: DateTime(2022),
      country: 'US',
      language: 'en-US',
      rank: -1,
      score: .0,
      topic: 'topic',
    ),
    stackId: StackId.nil(),
  );

  setUp(() async {
    engine = MockAppDiscoveryEngine();
    analyticsService = MockAnalyticsService();
    marketingAnalyticsService = MockMarketingAnalyticsService();
    documentRepository = MockDocumentRepository();

    di.registerSingletonAsync<LogDocumentTimeUseCase>(
        () => Future.value(LogDocumentTimeUseCase(engine)));
    di.registerSingleton<DiscoveryCardObservationUseCase>(
        DiscoveryCardObservationUseCase());
    di.registerSingleton<DiscoveryCardMeasuredObservationUseCase>(
        DiscoveryCardMeasuredObservationUseCase());
    di.registerLazySingleton<SendAnalyticsUseCase>(() => SendAnalyticsUseCase(
          analyticsService,
          marketingAnalyticsService,
        ));
    di.registerLazySingleton<ChangeDocumentFeedbackUseCase>(
        () => ChangeDocumentFeedbackUseCase(engine, documentRepository));

    when(analyticsService.send(any)).thenAnswer((_) => Future.value());

    when(engine.logDocumentTime(
      documentId: anyNamed('documentId'),
      seconds: anyNamed('seconds'),
      mode: anyNamed('mode'),
    )).thenAnswer(
      (_) => Future.value(const ClientEventSucceeded()),
    );
  });

  blocTest<_TestBloc, bool>(
    'WHEN observing a document THEN this is logged with the engine',
    build: () => _TestBloc(),
    act: (bloc) async {
      bloc.observeDocument(
        document: document,
        mode: DocumentViewMode.story,
      );

      await Future.delayed(const Duration(milliseconds: 1500));

      bloc.observeDocument(
        document: document,
        mode: DocumentViewMode.reader,
      );
    },
    verify: (manager) {
      expect(manager.state, equals(false));
      verify(engine.logDocumentTime(
        documentId: document.documentId,
        mode: DocumentViewMode.story,
        seconds: 1,
      ));
      verifyNoMoreInteractions(engine);
    },
  );
}

class _TestBloc extends Cubit<bool>
    with
        UseCaseBlocHelper<bool>,
        SingletonSubscriptionObserver<bool>,
        ObserveDocumentMixin<bool> {
  _TestBloc() : super(false);

  @override
  bool isDocumentCurrentlyDisplayed(Document document) => true;
}
