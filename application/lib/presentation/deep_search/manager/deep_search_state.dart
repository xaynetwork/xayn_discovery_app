import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

abstract class DeepSearchState {
  const factory DeepSearchState.init() = InitState;
  const factory DeepSearchState.loading() = LoadingState;
  const factory DeepSearchState.success(Set<Document> results) =
      SearchSuccessState;
  const factory DeepSearchState.failure() = SearchFailureState;
}

class InitState implements DeepSearchState {
  const InitState();
}

class LoadingState implements DeepSearchState {
  const LoadingState();
}

class SearchSuccessState implements DeepSearchState {
  final Set<Document> results;

  const SearchSuccessState(this.results);
}

class SearchFailureState implements DeepSearchState {
  const SearchFailureState();
}
