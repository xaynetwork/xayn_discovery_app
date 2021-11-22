import 'dart:async';

import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/document_feedback_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as xayn;
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/base_events.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/search_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:share/share.dart';

/// Mock implementation.
/// This will be deprecated once the real discovery engine is available.
@lazySingleton
class DiscoveryEngineManager extends Cubit<DiscoveryEngineState>
    with UseCaseBlocHelper<DiscoveryEngineState>
    implements xayn.DiscoveryEngine {
  final ConnectivityUriUseCase _connectivityUseCase;
  final CreateHttpRequestUseCase _createHttpRequestUseCase;
  final InvokeApiEndpointUseCase _invokeApiEndpointUseCase;

  final StreamController<ClientEvent> _onClientEvent =
      StreamController<ClientEvent>();
  late final StreamSubscription<ClientEvent> _clientEventSubscription;

  late final UseCaseSink<String, ApiEndpointResponse> _handleQuery;

  bool _isLoading = false;

  Sink<ClientEvent> get onClientEvent => _onClientEvent.sink;

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
          .followedBy(LogUseCase((it) => 'will fetch $it'))
          .followedBy(_invokeApiEndpointUseCase)
          .scheduleComputeState(
            consumeEvent: (data) => !data.isComplete,
            run: (data) => _isLoading = !data.isComplete,
          )
          .followedBy(
            LogUseCase(
              (it) => 'did fetch ${it.results.length} results',
              when: (it) => it.isComplete,
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
          return const DiscoveryEngineState.loading();
        }

        if (a != null) {
          return DiscoveryEngineState(results: a.results, isComplete: true);
        }
      });

  void _handleClientEvent(ClientEvent event) {
    if (event is SearchRequested) {
      _handleSearchEvent(event);
    } else if (event is xayn.DocumentFeedbackChanged) {
      _handleDocumentFeedbackChanged(event);
    }
  }

  void _handleSearchEvent(SearchRequested event) => _handleQuery(event.term);

  void _handleDocumentFeedbackChanged(xayn.DocumentFeedbackChanged event) {
    // ignore: avoid_print
    print('DocumentFeedbackChanged has been called: ${event.feedback}');
  }
}

/// Since [DocumentFeedbackUseCase] depends on [DiscoveryEngineManager]
/// We can't use it inside [DiscoveryEngineManager] since it creates
/// circular dependency issue
///
/// [DiscoveryCardActionsManager] is used to call public functions inside
/// [DocumentFeedbackUseCase]
@injectable
class DiscoveryCardActionsManager {
  final DocumentFeedbackUseCase _documentFeedbackUseCase;
  DiscoveryCardActionsManager(
    this._documentFeedbackUseCase,
  );

  void likeDocument(Document document) {
    final feedback = document.isNotRelevant
        ? xayn.DocumentFeedback.neutral
        : xayn.DocumentFeedback.positive;
    _documentFeedbackUseCase.call(
      xayn.DocumentFeedbackChanged(
        document.documentId,
        feedback,
      ),
    );
  }

  void dislikeDocument(Document document) {
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

  void shareUri(Uri uri) => Share.share(uri.toString());
}
