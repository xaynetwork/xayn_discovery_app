import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/restore_feed_succeeded.dart';
import 'package:xayn_discovery_app/domain/model/session/session.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/observe_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/singleton_subscription_observer.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

mixin RequestFeedMixin<T extends DiscoveryState>
    on SingletonSubscriptionObserver<T> {
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

  /// This method is implemented in [ObserveDocumentMixin.observeDocument].
  /// We need the abstract version here as well, so that it can be called from
  /// this mixin too.
  void observeDocument({
    Document? document,
    DocumentViewMode? mode,
  });

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

    logger.i('[BEGIN RequestFeedMixin logging]');

    late final fetchCardIndexUseCase = di.get<FetchCardIndexUseCase>();
    final updateSessionUseCase = di.get<UpdateSessionUseCase>();
    final fetchSessionUseCase = di.get<FetchSessionUseCase>();
    final session = await fetchSessionUseCase.singleOutput(none);
    final sessionUpdate = session.copyWith(didRequestFeed: true);

    onResetParameters([int nextIndex = 0]) => (_) => resetParameters(nextIndex);
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

    onCloseExplicitFeedback([_]) => _closeExplicitFeedback(
          {
            ...state.cards
                .where((it) => it.type == CardType.document)
                .map((it) => it.document.documentId)
          },
        );

    onError(Object e, StackTrace? s) =>
        this.onError(e, s ?? StackTrace.current);

    // loads the old session's feed, and keeps only 1 document,
    // namely the very one that was being displayed as the "main" card,
    // in the previous app session.
    makeCleanedUpOldFeed(Stream<Session> stream) => stream
        .take(1)
        .doOnData((_) => logger.i('- doRequestFeed'))
        // restore the feed from the previous app session
        .doRequestFeed()
        .doOnData((_) => logger.i('- onRestore'))
        // convert all to DocumentId's
        .map(onRestore)
        .doOnData((_) => logger.i('- onCloseOldDocuments'))
        // close all documents except the single one that the user had
        // up in a previous session
        .asyncMap(onCloseOldDocuments)
        .doOnData((_) => logger.i('- release stream'))
        // release the [stream] for consumption
        .doOnData(_preambleCompleter.complete);

    // pulls in fresh/actual documents
    makeActualizeFeed(Stream<None> stream) => stream
        .doOnData((_) => logger.i('- doResetFeedAndRequestNextBatch'))
        // we now have just 1 document, so fetch a next batch of fresh ones
        .doResetFeedAndRequestNextBatch()
        .doOnData((_) => logger.i('- onResetParameters'))
        // increment the feed index, so that the old document is moved up
        .doOnData(onResetParameters(1));

    // rebuilds the feed when the market(s) change
    makeMarketChangedFeed(Stream<EngineEvent> stream) => stream
        .doOnData((_) => logger.i('- stop document observation'))
        .doOnData((_) => observeDocument())
        .doOnData((_) => logger.i('- onCloseExplicitFeedback'))
        // cleanup the old feed, from the previous market
        .asyncMap(onCloseExplicitFeedback)
        .doOnData((_) => logger.i('- onResetParameters'))
        // reset the feed to the start index
        .doOnData(onResetParameters())
        .doOnData((_) => logger.i('- doResetFeedAndRequestNextBatch'))
        // finally load documents in the new market
        .doResetFeedAndRequestNextBatch();

    consume(updateSessionUseCase, initialData: sessionUpdate).transform(
      (out) {
        final cleanedUpOldFeed = makeCleanedUpOldFeed(out);
        final actualizedFeed = makeActualizeFeed(cleanedUpOldFeed);

        return makeMarketChangedFeed(actualizedFeed);
      },
    ).autoSubscribe(onError: onError);
  }

  Future<void> _closeExplicitFeedback(Set<DocumentId> documents) async {
    final crudExplicitDocumentFeedbackUseCase =
        di.get<CrudExplicitDocumentFeedbackUseCase>();

    for (final id in documents) {
      crudExplicitDocumentFeedbackUseCase(
        DbCrudIn.remove(id.uniqueId),
      );
    }
  }
}

extension _StreamExtension<T> on Stream<T> {
  Stream<EngineEvent> doRequestFeed() =>
      mapTo(none).followedBy(di.get<RequestFeedUseCase>());

  Stream<EngineEvent> doRequestNextBatch() =>
      mapTo(none).followedBy(di.get<RequestNextFeedBatchUseCase>());

  Stream<EngineEvent> doResetFeedAndRequestNextBatch() =>
      doRequestFeed().doRequestNextBatch();
}
