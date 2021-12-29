import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/handlers/fold.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/mixins/engine_events_mixin.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/mixins/search_mixin.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';

abstract class ActiveSearchNavActions {
  void onHomeNavPressed();

  void onAccountNavPressed();
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
        TempSearchMixin<ActiveSearchState>
    implements ActiveSearchNavActions {
  ActiveSearchManager(
    this._activeSearchNavActions,
  ) : super(ActiveSearchState.empty());

  final ActiveSearchNavActions _activeSearchNavActions;

  @override
  Future<ActiveSearchState?> computeState() async =>
      fold(engineEvents).foldAll((engineEvent, errorReport) {
        if (errorReport.isNotEmpty) {
          return state.copyWith(
            isInErrorState: true,
          );
        }

        if (documents.isNotEmpty) {
          return state.copyWith(
            results: documents,
            isLoading: isLoading,
            isComplete: !isLoading,
            isInErrorState: false,
          );
        }
      });

  @override
  void onAccountNavPressed() => _activeSearchNavActions.onAccountNavPressed();

  @override
  void onHomeNavPressed() => _activeSearchNavActions.onHomeNavPressed();
}
