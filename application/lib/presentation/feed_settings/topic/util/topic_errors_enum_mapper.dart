import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/topic/topic_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

@lazySingleton
class TopicErrorsEnumMapper {
  String mapEnumToString(TopicUseCaseError errorEnum) {
    String msg;

    switch (errorEnum) {
      case TopicUseCaseError.tryingToAddCustomTopicWithInvalidName:
        msg = R.strings.feedSettingsScreenMaxTopicsError;
        break;
    }
    return msg;
  }
}
