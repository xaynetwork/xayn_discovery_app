import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';

part 'topics_state.freezed.dart';

@freezed
class TopicsState with _$TopicsState {
  const TopicsState._();

  const factory TopicsState({
    @Default(<Topic>{}) Set<Topic> selectedTopics,
    @Default(<Topic>{}) Set<Topic> suggestedTopics,
    @Default(ErrorObject()) ErrorObject error,
    @Default('') String newTopicName,
  }) = _TopicsState;
}
