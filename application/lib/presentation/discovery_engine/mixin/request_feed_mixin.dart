import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/are_markets_outdated_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/check_markets_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
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

  void resetParameters();

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

    final requestFeedUseCase = di.get<RequestFeedUseCase>();
    final areMarketsOutdatedUseCase = di.get<AreMarketsOutdatedUseCase>();
    final areMarketsOutdated =
        await areMarketsOutdatedUseCase.singleOutput(none);

    if (areMarketsOutdated) {
      final changeMarketsUseCase = di.get<CheckMarketsUseCase>();

      consume(requestFeedUseCase, initialData: none)
          .transform(
            (out) => out
                .doOnData((_) => resetParameters())
                .map((it) => it is RestoreFeedSucceeded
                    ? it.items.map((it) => it.documentId).toSet()
                    : const <DocumentId>{})
                .asyncMap(_closeExplicitFeedback)
                .mapTo(none)
                .followedBy(changeMarketsUseCase)
                .doOnData(_preambleCompleter.complete)
                .mapTo(none)
                .followedBy(requestNextFeedBatchUseCase),
          )
          .autoSubscribe(
              onError: (e, s) => onError(e, s ?? StackTrace.current));
    } else {
      final maybeRequestNextBatchUseCase =
          _MaybeRequestNextBatchWhenEmptyUseCase(requestNextFeedBatchUseCase);

      _preambleCompleter.complete();

      consume(requestFeedUseCase, initialData: none)
          .transform((out) => out.switchedBy(maybeRequestNextBatchUseCase))
          .autoSubscribe(
              onError: (e, s) => onError(e, s ?? StackTrace.current));
    }
  }

  Future<void> _closeExplicitFeedback(Set<DocumentId> documents) async {
    final closeDocumentsUseCase = di.get<CloseFeedDocumentsUseCase>();
    final crudExplicitDocumentFeedbackUseCase =
        di.get<CrudExplicitDocumentFeedbackUseCase>();

    for (final id in documents) {
      crudExplicitDocumentFeedbackUseCase(
        DbEntityCrudUseCaseIn.remove(id.uniqueId),
      );
    }

    await closeDocumentsUseCase(documents);
  }
}

class _MaybeRequestNextBatchWhenEmptyUseCase
    extends UseCase<EngineEvent, EngineEvent> {
  final RequestNextFeedBatchUseCase maybeRequestNextBatchUseCase;

  _MaybeRequestNextBatchWhenEmptyUseCase(this.maybeRequestNextBatchUseCase);

  @override
  Stream<EngineEvent> transaction(EngineEvent param) async* {
    if (param is RestoreFeedSucceeded && param.items.isEmpty) {
      yield await maybeRequestNextBatchUseCase.singleOutput(none);
    }

    yield param;
  }
}
