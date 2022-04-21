import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_feed_settings_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/update_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/fetch_card_index_use_case.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin RequestFeedMixin<T extends DiscoveryState> on UseCaseBlocHelper<T> {
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
    late final fetchCardIndexUseCase = di.get<FetchCardIndexUseCase>();
    final updateSessionUseCase = di.get<UpdateSessionUseCase>();
    final requestFeedUseCase = di.get<RequestFeedUseCase>();
    final fetchSessionUseCase = di.get<FetchSessionUseCase>();
    final session = await fetchSessionUseCase.singleOutput(none);
    final sessionUpdate = session.copyWith(didRequestFeed: true);

    _didStartConsuming = true;

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

    onCloseExplicitFeedback([_]) =>
        _closeExplicitFeedback({...state.results.map((it) => it.documentId)});

    onError(Object e, StackTrace? s) =>
        this.onError(e, s ?? StackTrace.current);

    consume(updateSessionUseCase, initialData: sessionUpdate)
        .transform(
          (out) => out
              .take(1)
              .doRequestFeed()
              .map(onRestore)
              .asyncMap(onCloseOldDocuments)
              .doOnData(_preambleCompleter.complete)
              .followedBy(requestFeedUseCase)
              .doRequestNextBatch()
              .doOnData(onResetParameters(1))
              .whereMarketsChanged()
              // following section triggers each time markets change
              .asyncMap(onCloseExplicitFeedback)
              .finalizeFeedMarketsChange()
              .doOnData(onResetParameters())
              .doResetFeedAndRequestNextBatch(),
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

extension _StreamExtension<T> on Stream<T> {
  Stream<EngineEvent> doRequestFeed() =>
      mapTo(none).followedBy(di.get<RequestFeedUseCase>());

  Stream<EngineEvent> doRequestNextBatch() =>
      mapTo(none).followedBy(di.get<RequestNextFeedBatchUseCase>());

  Stream<EngineEvent> doResetFeedAndRequestNextBatch() =>
      doRequestFeed().doRequestNextBatch();

  Stream<bool> whereMarketsChanged() => mapTo(const DbCrudIn.watchAllChanged())
      .followedBy(di.get<CrudFeedSettingsUseCase>())
      .mapTo(FeedType.feed)
      .followedBy(di.get<AreMarketsOutdatedUseCase>())
      .where((didMarketsChange) => didMarketsChange);

  Stream<EngineEvent> finalizeFeedMarketsChange() =>
      mapTo(FeedType.feed).followedBy(di.get<UpdateMarketsUseCase>());
}
