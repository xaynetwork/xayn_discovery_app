import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/handlers/fold.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/engine_events_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/temp/search_mixin.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

abstract class ActiveSearchNavActions {
  void onHomeNavPressed();

  void onPersonalAreaNavPressed();

  void onCardDetailsPressed(Document document);

  void onBackPressed();
}

/// Manages the state for the active search screen.
///
/// It consumes events from the discovery engine and emits a state
/// which contains a list of discovery news items which should be displayed
/// in a list format by widgets.
@injectable
class ActiveSearchManager extends Cubit<ActiveSearchState>
    with
        UseCaseBlocHelper<ActiveSearchState>,
        EngineEventsMixin<ActiveSearchState>,
        SearchMixin<ActiveSearchState>
    implements ActiveSearchNavActions {
  ActiveSearchManager(
    this._activeSearchNavActions,
  ) : super(ActiveSearchState.empty());

  final ActiveSearchNavActions _activeSearchNavActions;

  @override
  Future<ActiveSearchState?> computeState() async =>
      fold(engineEvents).foldAll((engineEvent, errorReport) {
        if (errorReport.isNotEmpty || engineEvent is EngineExceptionRaised) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (engineEvent is FeedRequestSucceeded) {
          final currentResults = state.results ?? const <Document>[];

          return state.copyWith(
            results: {...currentResults, ...engineEvent.items},
            isLoading: isLoading,
            isComplete: !isLoading,
            isInErrorState: false,
          );
        }
      });

  @override
  void onPersonalAreaNavPressed() =>
      _activeSearchNavActions.onPersonalAreaNavPressed();

  @override
  void onHomeNavPressed() => _activeSearchNavActions.onHomeNavPressed();

  @override
  void onCardDetailsPressed(Document document) =>
      _activeSearchNavActions.onCardDetailsPressed(document);

  @override
  void onBackPressed() => _activeSearchNavActions.onBackPressed();
}
