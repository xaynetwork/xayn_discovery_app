import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../presentation/test_utils/fakes.dart';
import '../../presentation/test_utils/utils.dart';

void main() {
  ActiveSearchManager buildManager() =>
      ActiveSearchManager(MockActiveSearchNavActions());
  late DiscoveryEngine engine;

  setUp(() async {
    await configureTestDependencies();
    engine = MockDiscoveryEngine();
    di
      ..unregister<DiscoveryEngine>()
      ..registerSingleton<DiscoveryEngine>(engine);
  });

  blocTest<ActiveSearchManager, ActiveSearchState>(
    'GIVEN fresh manager THEN the state is ActiveSearchState.empty()',
    build: () {
      when(engine.engineEvents).thenAnswer((_) => const Stream.empty());
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state, ActiveSearchState.empty());
    },
  );

  blocTest<ActiveSearchManager, ActiveSearchState>(
    'GIVEN use case emits results THEN the state contains results',
    build: () {
      when(engine.engineEvents).thenAnswer(
          (ctx) => Stream.value(RestoreFeedSucceeded([fakeDocument])));
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state.isComplete, isTrue);
      expect(bloc.state.isInErrorState, isFalse);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.results, isNotEmpty);
    },
  );

  blocTest<ActiveSearchManager, ActiveSearchState>(
    'GIVEN use case throws an error THEN the error state is true',
    build: () {
      when(engine.engineEvents).thenAnswer((ctx) => Stream.value(
          const EngineExceptionRaised(EngineExceptionReason.genericError)));
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state.isInErrorState, isTrue);
    },
  );
}
