import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as xayn;

/// Mock implementation.
/// This will be deprecated once the real discovery engine is available.
@lazySingleton
class DiscoveryEngineManager extends Cubit<DiscoveryEngineState>
    with UseCaseBlocHelper<DiscoveryEngineState>
    implements xayn.DiscoveryEngine {
  final ConnectivityUriUseCase _connectivityUseCase;
  final CreateHttpRequestUseCase _createHttpRequestUseCase;
  final InvokeApiEndpointUseCase _invokeApiEndpointUseCase;

  final StreamController<xayn.ClientEvent> _onClientEvent =
      StreamController<xayn.ClientEvent>();
  late final StreamSubscription<xayn.ClientEvent> _clientEventSubscription;

  late final UseCaseSink<String, ApiEndpointResponse> _handleQuery;

  bool _isLoading = false;

  Sink<xayn.ClientEvent> get onClientEvent => _onClientEvent.sink;

  DiscoveryEngineManager(
    this._connectivityUseCase,
    this._createHttpRequestUseCase,
    this._invokeApiEndpointUseCase,
  ) : super(const DiscoveryEngineState.initial()) {
    _initGeneral();
    _initHandlers();
  }

  @override
  Future<void> close() {
    _onClientEvent.close();
    _clientEventSubscription.cancel();

    return super.close();
  }

  void _initGeneral() {
    _clientEventSubscription = _onClientEvent.stream.listen(_handleClientEvent);
  }

  void _initHandlers() {
    _handleQuery = pipe(_createHttpRequestUseCase).transform(
      (out) => out
          .followedBy(_connectivityUseCase)
          .followedBy(LogUseCase(
            (it) => 'will fetch $it',
            logger: logger,
          ))
          .followedBy(_invokeApiEndpointUseCase)
          .scheduleComputeState(
            consumeEvent: (data) => !data.isComplete,
            run: (data) {
              _isLoading = !data.isComplete;
            },
          )
          .followedBy(
            LogUseCase(
              (it) => 'did fetch ${it.results.length} results',
              when: (it) => it.isComplete,
              logger: logger,
            ),
          ),
    );
  }

  @override
  Future<DiscoveryEngineState?> computeState() async =>
      fold(_handleQuery).foldAll((a, errorReport) {
        if (errorReport.isNotEmpty) {
          final errorAndStackTrace = errorReport.of(_handleQuery)!;

          return DiscoveryEngineState.error(
            error: errorAndStackTrace.error,
            stackTrace: errorAndStackTrace.stackTrace,
          );
        }

        if (_isLoading) {
          return DiscoveryEngineState(
              results: state.results, isComplete: false);
        }

        if (a != null) {
          return DiscoveryEngineState(results: a.results, isComplete: true);
        }
      });

  void _handleClientEvent(xayn.ClientEvent event) {
    if (event is xayn.FeedRequested) {
      requestFeed();
    } else if (event is xayn.DocumentFeedbackChanged) {
      _handleDocumentFeedbackChanged(event);
    }
  }

  void _handleDocumentFeedbackChanged(xayn.DocumentFeedbackChanged event) {
    // ignore: avoid_print
    print('DocumentFeedbackChanged has been called: ${event.feedback}');
  }

  @override
  Future<xayn.EngineEvent> changeConfiguration(
      {String? feedMarket, int? maxItemsPerFeedBatch}) {
    // TODO: implement changeConfiguration
    throw UnimplementedError();
  }

  @override
  Future<xayn.EngineEvent> changeDocumentFeedback(
      {required xayn.DocumentId documentId,
      required xayn.DocumentFeedback feedback}) {
    // TODO: implement changeDocumentFeedback
    throw UnimplementedError();
  }

  @override
  Future<xayn.EngineEvent> closeFeedDocuments(
      Set<xayn.DocumentId> documentIds) {
    // TODO: implement closeFeedDocuments
    throw UnimplementedError();
  }

  @override
  // TODO: implement engineEvents
  Stream<xayn.EngineEvent> get engineEvents => throw UnimplementedError();

  @override
  Future<xayn.EngineEvent> logDocumentTime(
      {required xayn.DocumentId documentId,
      required xayn.DocumentViewMode mode,
      required int seconds}) {
    // TODO: implement logDocumentTime
    throw UnimplementedError();
  }

  @override
  Future<xayn.EngineEvent> requestFeed() async {
    _handleQuery('today');

    return const xayn.EngineEvent.feedRequestSucceeded([]);
  }

  @override
  Future<xayn.EngineEvent> requestNextFeedBatch() {
    // TODO: implement requestNextFeedBatch
    throw UnimplementedError();
  }

  @override
  Future<xayn.EngineEvent> resetEngine() {
    // TODO: implement resetEngine
    throw UnimplementedError();
  }
}

/// Since [DocumentFeedbackUseCase] depends on [DiscoveryEngineManager]
/// We can't use it inside [DiscoveryEngineManager] since it creates
/// circular dependency issue
///
/// [DiscoveryCardActionsManager] is used to call public functions inside
/// [DocumentFeedbackUseCase]
@lazySingleton
class DiscoveryCardActionsManager {
  final DocumentFeedbackUseCase _documentFeedbackUseCase;
  final ShareUriUseCase _shareUriUseCase;
  DiscoveryCardActionsManager(
    this._documentFeedbackUseCase,
    this._shareUriUseCase,
  );

  void likeDocument(xayn.Document document) {
    final feedback = document.isIrrelevant
        ? xayn.DocumentFeedback.neutral
        : xayn.DocumentFeedback.positive;
    _documentFeedbackUseCase.call(
      xayn.DocumentFeedbackChanged(
        document.documentId,
        feedback,
      ),
    );
  }

  void dislikeDocument(xayn.Document document) {
    final feedback = document.isRelevant
        ? xayn.DocumentFeedback.neutral
        : xayn.DocumentFeedback.negative;
    _documentFeedbackUseCase.call(
      xayn.DocumentFeedbackChanged(
        document.documentId,
        feedback,
      ),
    );
  }

  void shareUri(Uri uri) => _shareUriUseCase.call(uri);
}
