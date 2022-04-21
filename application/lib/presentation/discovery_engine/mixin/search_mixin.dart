import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_search_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_feed_settings_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_search_term_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_search_batch_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_search_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/restore_search_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/update_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin SearchMixin<T> on UseCaseBlocHelper<T> {
  late final RequestNextSearchBatchUseCase requestNextSearchBatchUseCase =
      di.get<RequestNextSearchBatchUseCase>();
  late final RequestSearchUseCase searchUseCase =
      di.get<RequestSearchUseCase>();
  UseCaseSink<None, EngineEvent>? _nextBatchUseCaseSink;
  UseCaseSink<String, EngineEvent>? _searchUseCaseSink;
  bool _didStartConsuming = false;
  String? _lastUsedSearchTerm;

  String? get lastUsedSearchTerm => _lastUsedSearchTerm;

  void search(String queryTerm) {
    _searchUseCaseSink ??= _getSearchUseCaseSink();
    _lastUsedSearchTerm = queryTerm;

    _searchUseCaseSink!(queryTerm);
  }

  void requestNextSearchBatch() {
    _nextBatchUseCaseSink ??= _getNextBatchUseCaseSink();

    _nextBatchUseCaseSink!(none);
  }

  void resetParameters();

  @override
  Stream<T> get stream {
    if (!_didStartConsuming) {
      _startConsuming();
    }

    return super.stream;
  }

  UseCaseSink<None, EngineEvent> _getNextBatchUseCaseSink() {
    return pipe(requestNextSearchBatchUseCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<String, EngineEvent> _getSearchUseCaseSink() {
    return pipe(searchUseCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  void _startConsuming() async {
    _didStartConsuming = true;

    final requestSearchUseCase = di.get<RestoreSearchUseCase>();
    final lastUsedSearchTerm =
        _lastUsedSearchTerm = await _restoreLastUsedSearchTerm();

    final closeSearchUseCase = di.get<CloseSearchUseCase>();
    final changeMarketsUseCase = di.get<UpdateMarketsUseCase>();

    onResetParameters(_) => resetParameters();
    onRestore(EngineEvent it) => it is RestoreSearchSucceeded
        ? {...it.items.map((it) => it.documentId)}
        : const <DocumentId>{};
    onError(Object e, StackTrace? s) =>
        this.onError(e, s ?? StackTrace.current);

    consume(requestSearchUseCase, initialData: none)
        .transform((out) => out
            .whereMarketsChanged()
            .doOnData(onResetParameters)
            .map(onRestore)
            .doOnData(_closeExplicitFeedback)
            .mapTo(none)
            .followedBy(closeSearchUseCase)
            .mapTo(FeedType.search)
            .followedBy(changeMarketsUseCase)
            .mapTo(lastUsedSearchTerm)
            .whereType<String>()
            .doOnData(search))
        .autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  Future<String?> _restoreLastUsedSearchTerm() async {
    final getSearchTermUseCase = di.get<GetSearchTermUseCase>();
    final result = await getSearchTermUseCase.singleOutput(none);

    return result is SearchTermRequestSucceeded ? result.searchTerm : null;
  }

  void _closeExplicitFeedback(Set<DocumentId> documents) {
    final crudExplicitDocumentFeedbackUseCase =
        di.get<CrudExplicitDocumentFeedbackUseCase>();

    for (final id in documents) {
      crudExplicitDocumentFeedbackUseCase(
        DbCrudIn.remove(id.uniqueId),
      );
    }
  }
}

extension _StreamExtension on Stream<EngineEvent> {
  Stream<EngineEvent> whereMarketsChanged() => switchMap(
        (engineEvent) => Stream.value(const DbCrudIn.watchAllChanged())
            .followedBy(di.get<CrudFeedSettingsUseCase>())
            .mapTo(FeedType.feed)
            .followedBy(di.get<AreMarketsOutdatedUseCase>())
            .where((didMarketsChange) => didMarketsChange)
            .mapTo(engineEvent),
      );
}
