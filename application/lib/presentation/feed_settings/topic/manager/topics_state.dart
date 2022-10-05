import 'package:freezed_annotation/freezed_annotation.dart';

part 'topics_state.freezed.dart';

@freezed
class TopicsState with _$TopicsState {
  const TopicsState._();

  const factory TopicsState({
    @Default(<String>{}) Set<String> selectedTopics,
    @Default(<String>{}) Set<String> suggestedTopics,
  }) = _TopicsState;
}
