import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

part 'active_search_state.freezed.dart';

/// The state of the [ActiveSearchManager].
@freezed
class ActiveSearchState with _$ActiveSearchState {
  const ActiveSearchState._();

  const factory ActiveSearchState({
    Set<Document>? results,
    required bool isComplete,
    required bool isLoading,
    required bool isInErrorState,
  }) = _ActiveSearchState;

  factory ActiveSearchState.empty() => const ActiveSearchState(
        isComplete: false,
        isLoading: false,
        isInErrorState: false,
      );

  factory ActiveSearchState.loading() => const ActiveSearchState(
        isComplete: false,
        isLoading: true,
        isInErrorState: false,
      );
}
