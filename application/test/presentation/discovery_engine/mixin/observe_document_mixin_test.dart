import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_document_time_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_card_observation_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;
  final document = Document(
    documentId: DocumentId(),
    feedback: DocumentFeedback.neutral,
    personalizedRank: 0,
    nonPersonalizedRank: 0,
    isActive: true,
    webResource: WebResource(
      title: '',
      snippet: '',
      url: Uri.base,
      displayUrl: Uri.base,
      datePublished: DateTime(2022),
      provider: WebResourceProvider(
        name: '',
        thumbnail: Uri.base,
      ),
    ),
  );

  setUp(() async {
    engine = MockDiscoveryEngine();

    di.registerSingletonAsync<LogDocumentTimeUseCase>(
        () => Future.value(LogDocumentTimeUseCase(engine)));

    di.registerSingleton<DiscoveryCardObservationUseCase>(
        DiscoveryCardObservationUseCase());

    di.registerSingleton<DiscoveryCardMeasuredObservationUseCase>(
        DiscoveryCardMeasuredObservationUseCase());

    when(engine.logDocumentTime(
      documentId: anyNamed('documentId'),
      seconds: anyNamed('seconds'),
      mode: anyNamed('mode'),
    )).thenAnswer(
      (_) => Future.value(const ClientEventSucceeded()),
    );
  });

  blocTest<TestBloc, bool>(
    'WHEN observing a document THEN this is logged with the engine',
    build: () => TestBloc(),
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

class TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, ObserveDocumentMixin<bool> {
  TestBloc() : super(false);
}
