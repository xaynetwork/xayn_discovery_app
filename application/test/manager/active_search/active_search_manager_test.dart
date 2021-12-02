import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';
import 'package:xayn_discovery_engine/src/domain/models/search_type.dart';

import 'active_search_manager_test.mocks.dart';

@GenerateMocks([DiscoveryEngineResultsUseCase, Document,])
void main() {
  late MockDiscoveryEngineResultsUseCase useCase;

  const testParams = DiscoveryEngineResultsParam(
    searchTerm: 'xayn',
    searchTypes: [SearchType.web],
  );
  final resultState = DiscoveryEngineState(
    results: [MockDocument()],
    isComplete: true,
  );

  ActiveSearchManager buildManager() => ActiveSearchManager(useCase);

  setUp(() {
    useCase = MockDiscoveryEngineResultsUseCase();
    when(useCase.transform(any)).thenAnswer((_) => Stream.value(testParams));
  });

  blocTest<ActiveSearchManager, ActiveSearchState>(
    'GIVEN fresh manager THEN the state is ActiveSearchState.empty()',
    build: () {
      when(useCase.transform(any)).thenAnswer((_) => const Stream.empty());
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state, ActiveSearchState.empty());
    },
  );

  blocTest<ActiveSearchManager, ActiveSearchState>(
    'GIVEN use case emits results THEN the state contains results',
    build: () {
      when(useCase.transform(any)).thenAnswer((_) => Stream.value(testParams));
      when(useCase.transaction(any))
          .thenAnswer((_) => Stream.value(resultState));
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
      when(useCase.transform(any)).thenAnswer((_) => Stream.value(testParams));
      when(useCase.transaction(any)).thenAnswer((_) async* {
        throw ArgumentError('bad data!');
      });
      return buildManager();
    },
    verify: (bloc) {
      expect(bloc.state.isInErrorState, isTrue);
    },
  );
}
