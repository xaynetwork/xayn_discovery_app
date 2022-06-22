import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

abstract class DeepSearchState {
  const DeepSearchState();
  Set<Document> get results => {};
  ErrorState reportError() => const ErrorState();
}

class InitState extends DeepSearchState {
  const InitState();
  LoadingState requestDeepSearch() => const LoadingState();
}

class ErrorState extends DeepSearchState {
  const ErrorState();
}

class LoadingState extends DeepSearchState {
  const LoadingState();
  SearchSuccessState requestSucceeded(Set<Document> results) =>
      SearchSuccessState(results);
  SearchFailureState requestFailed() => const SearchFailureState();
}

class SearchSuccessState extends DeepSearchState {
  @override
  final Set<Document> results;

  const SearchSuccessState(this.results);

  DocumentViewState openDocument(Document document) =>
      DocumentViewState(results, document);
}

class SearchFailureState extends DeepSearchState {
  const SearchFailureState();
}

class DocumentViewState extends DeepSearchState {
  @override
  final Set<Document> results;
  final Document document;

  const DocumentViewState(this.results, this.document);

  SearchSuccessState goBack() => SearchSuccessState(results);
}
