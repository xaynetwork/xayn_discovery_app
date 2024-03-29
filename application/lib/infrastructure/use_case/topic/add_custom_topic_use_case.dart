import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/topic/topic_use_cases_errors.dart';

const _maxTopicNameLength = 48;

@injectable
class AddCustomTopicUseCase extends UseCase<String, Topic> {
  AddCustomTopicUseCase();

  @override
  Stream<Topic> transaction(String param) async* {
    final topicNameTrimmed = param.trim();
    if (topicNameTrimmed.trim().length > _maxTopicNameLength) {
      throw TopicUseCaseError.tryingToAddCustomTopicWithInvalidName;
    }

    yield Topic(topicNameTrimmed);
  }
}
