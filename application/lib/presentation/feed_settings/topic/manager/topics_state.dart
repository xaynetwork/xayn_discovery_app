import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';

part 'topics_state.freezed.dart';

@freezed
class TopicsState with _$TopicsState {
  const TopicsState._();

  const factory TopicsState({
    @Default(<String>{}) Set<String> selectedTopics,
    @Default(<String>{}) Set<String> suggestedTopics,
    @Default(ErrorObject()) ErrorObject error,
    @Default('') String newTopic,
  }) = _TopicsState;
}
