import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const SearchState._();

  const factory SearchState({
    @Default(<Document>[]) List<Document> results,
    @Default(false) bool isComplete,
  }) = _SearchState;
}
