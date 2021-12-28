import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/presentation/search_manager/search_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class SearchManager extends Cubit<SearchState>
    with UseCaseBlocHelper<SearchState> {
  final ConnectivityUriUseCase _connectivityUseCase;
  final CreateHttpRequestUseCase _createHttpRequestUseCase;
  final InvokeApiEndpointUseCase _invokeApiEndpointUseCase;

  late final UseCaseSink<String, ApiEndpointResponse> _handleQuery;

  bool _isLoading = false;

  SearchManager(
    this._connectivityUseCase,
    this._createHttpRequestUseCase,
    this._invokeApiEndpointUseCase,
  ) : super(const SearchState()) {
    _initHandlers();
  }

  void search(String searchTerm) => _handleQuery(searchTerm);

  @override
  Future<SearchState?> computeState() async =>
      fold(_handleQuery).foldAll((a, errorReport) {
        if (errorReport.isNotEmpty) {
          final errorAndStackTrace = errorReport.of(_handleQuery)!;

          logger.e(
              '${errorAndStackTrace.error}: ${errorAndStackTrace.stackTrace}');

          return null;
        }

        if (_isLoading) {
          return SearchState(
            results: state.results,
            isComplete: false,
          );
        }

        if (a != null) {
          return SearchState(
            results: a.results,
            isComplete: true,
          );
        }
      });

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
}
