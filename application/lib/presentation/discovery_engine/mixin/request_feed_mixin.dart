import 'dart:async';

import 'package:flutter/foundation.dart';
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

  /// indicates that the request is the first one after app startup when true
  static bool isFirstRunAfterAppStart = true;

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

    if (areMarketsOutdated) {
      _consumeWithChangedMarkets();
    } else if (isFirstRunAfterAppStart) {
      _consumeOnSessionStart();
    } else {
      _consumeNormally();
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

  void _consumeOnSessionStart() {
    late final fetchCardIndexUseCase = di.get<FetchCardIndexUseCase>();
    final requestFeedUseCase = di.get<RequestFeedUseCase>();

    isFirstRunAfterAppStart = false;

    onResetParameters(int nextIndex) => (_) => resetParameters(nextIndex);
    onRestore(EngineEvent it) => it is RestoreFeedSucceeded
        ? it.items.map((it) => it.documentId).toSet()
        : const <DocumentId>{};
    onPartition(Set<DocumentId> it) async {
      final lastKnownFeedIndex =
          await fetchCardIndexUseCase.singleOutput(FeedType.feed);

      return it.partition((index) =>
          index < lastKnownFeedIndex || index > lastKnownFeedIndex + 1);
    }

    onCloseHeadAndReturnTail(_PartitionedIterable<DocumentId> it) async {
      if (it.head.isNotEmpty) {
        await _closeExplicitFeedback(it.head.toSet());
      }

      return it.tail;
    }

    onError(Object e, StackTrace? s) =>
        this.onError(e, s ?? StackTrace.current);

    consume(requestFeedUseCase, initialData: none)
        .transform(
          (out) => out
              .doOnData(onResetParameters(0))
              .map(onRestore)
              .asyncMap(onPartition)
              .asyncMap(onCloseHeadAndReturnTail)
              .doOnData(_preambleCompleter.complete)
              .mapTo(none)
              .followedBy(requestFeedUseCase)
              .mapTo(none)
              .followedBy(requestNextFeedBatchUseCase)
              .doOnData(onResetParameters(2)),
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

class _PartitionedIterable<T> {
  final Iterable<T> head, tail;

  const _PartitionedIterable({
    required this.head,
    required this.tail,
  });
}

extension _IterableExtension<T> on Iterable<T> {
  _PartitionedIterable<T> partition(bool Function(int) shiftToHead) {
    final head = <T>[], tail = <T>[];

    for (var i = 0, len = length; i < len; i++) {
      final item = elementAt(i);

      if (shiftToHead(i)) {
        head.add(item);
      } else {
        tail.add(item);
      }
    }

    return _PartitionedIterable(head: head, tail: tail);
  }
}
