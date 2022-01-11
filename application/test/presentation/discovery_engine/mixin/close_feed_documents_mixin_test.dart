import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/close_feed_documents_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;
  final documents = {DocumentId()};

  setUp(() async {
    engine = MockDiscoveryEngine();

    di.registerSingletonAsync<CloseFeedDocumentsUseCase>(
        () => Future.value(CloseFeedDocumentsUseCase(engine)));

    when(engine.closeFeedDocuments(any)).thenAnswer(
      (_) => Future.value(const ClientEventSucceeded()),
    );
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
}

class _TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, CloseFeedDocumentsMixin<bool> {
  _TestBloc() : super(false);
}
