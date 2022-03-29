import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/update_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin RequestFeedMixin<T> on UseCaseBlocHelper<T> {
  late final RequestNextFeedBatchUseCase requestNextFeedBatchUseCase =
      di.get<RequestNextFeedBatchUseCase>();
  final Completer _preambleCompleter = Completer();
  UseCaseSink<None, EngineEvent>? _useCaseSink;
  bool _didStartConsuming = false;

  void requestNextFeedBatch() {
    _useCaseSink ??= _getUseCaseSink();

    _useCaseSink!(none);
  }

  void resetParameters([int nextCardIndex = 0]);

  @override
  Stream<T> get stream {
    if (!_didStartConsuming) {
      _startConsuming();
    }

    return Stream.fromFuture(_preambleCompleter.future)
        .asyncExpand((_) => super.stream);
  }

  UseCaseSink<None, EngineEvent> _getUseCaseSink() {
    return pipe(requestNextFeedBatchUseCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  void _startConsuming() async {
    _didStartConsuming = true;

    final areMarketsOutdatedUseCase = di.get<AreMarketsOutdatedUseCase>();
    final areMarketsOutdated =
        await areMarketsOutdatedUseCase.singleOutput(FeedType.feed);
    final fetchSessionUseCase = di.get<FetchSessionUseCase>();
    final session = await fetchSessionUseCase.singleOutput(none);

    if (areMarketsOutdated) {
      _consumeWithChangedMarkets();
    } else if (session.didRequestFeed) {
      _consumeNormally();
    } else {
      _consumeOnSessionStart();
    }
  }

  void _consumeNormally() {
    final requestFeedUseCase = di.get<RequestFeedUseCase>();

    _preambleCompleter.complete();

    consume(requestFeedUseCase, initialData: none)
        .transform(
            (out) => out.mapTo(none).switchedBy(requestNextFeedBatchUseCase))
        .autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  void _consumeOnSessionStart() async {
    late final fetchCardIndexUseCase = di.get<FetchCardIndexUseCase>();
    final updateSessionUseCase = di.get<UpdateSessionUseCase>();
    final requestFeedUseCase = di.get<RequestFeedUseCase>();
    final fetchSessionUseCase = di.get<FetchSessionUseCase>();
    final session = await fetchSessionUseCase.singleOutput(none);
    final sessionUpdate = session.copyWith(didRequestFeed: true);

    onResetParameters(int nextIndex) => (_) => resetParameters(nextIndex);
    onRestore(EngineEvent it) => it is RestoreFeedSucceeded
        ? it.items.map((it) => it.documentId).toSet()
        : const <DocumentId>{};
    onCloseOldDocuments(Set<DocumentId> it) async {
      final lastKnownFeedIndex =
          await fetchCardIndexUseCase.singleOutput(FeedType.feed);
      var index = 0;

      for (var i in it) {
        if (index != lastKnownFeedIndex) {
          await _closeExplicitFeedback({i});
        }

        index++;
      }

      return none;
    }

    onError(Object e, StackTrace? s) =>
        this.onError(e, s ?? StackTrace.current);

    consume(updateSessionUseCase, initialData: sessionUpdate)
        .transform(
          (out) => out
              .take(1)
              .mapTo(none)
              .followedBy(requestFeedUseCase)
              .map(onRestore)
              .asyncMap(onCloseOldDocuments)
              .doOnData(_preambleCompleter.complete)
              .followedBy(requestFeedUseCase)
              .mapTo(none)
              .followedBy(requestNextFeedBatchUseCase)
              .doOnData(onResetParameters(1)),
        )
        .autoSubscribe(onError: onError);
  }

  void _consumeWithChangedMarkets() {
    final requestFeedUseCase = di.get<RequestFeedUseCase>();
    final changeMarketsUseCase = di.get<UpdateMarketsUseCase>();

    onResetParameters(_) => resetParameters();
    onRestore(EngineEvent it) => it is RestoreFeedSucceeded
        ? it.items.map((it) => it.documentId).toSet()
        : const <DocumentId>{};
    onError(Object e, StackTrace? s) =>
        this.onError(e, s ?? StackTrace.current);

    consume(requestFeedUseCase, initialData: none)
        .transform(
          (out) => out
              .doOnData(onResetParameters)
              .map(onRestore)
              .asyncMap(_closeExplicitFeedback)
              .mapTo(FeedType.feed)
              .followedBy(changeMarketsUseCase)
              .doOnData(_preambleCompleter.complete)
              .mapTo(none)
              .followedBy(requestNextFeedBatchUseCase),
        )
        .autoSubscribe(onError: onError);
  }

  Future<void> _closeExplicitFeedback(Set<DocumentId> documents) async {
    final closeDocumentsUseCase = di.get<CloseFeedDocumentsUseCase>();
    final crudExplicitDocumentFeedbackUseCase =
        di.get<CrudExplicitDocumentFeedbackUseCase>();

    for (final id in documents) {
      crudExplicitDocumentFeedbackUseCase(
        DbCrudIn.remove(id.uniqueId),
      );
    }

    await closeDocumentsUseCase(documents);
  }
}
