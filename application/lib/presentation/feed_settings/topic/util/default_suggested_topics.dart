import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

Set<Topic> suggestedTopics = <Topic>{
  Topic.suggested(
    Keys.suggestedTopicsScience,
    R.strings.suggestedTopics.science,
  ),
  Topic.suggested(
    Keys.suggestedTopicsTechnology,
    R.strings.suggestedTopics.technology,
  ),
  Topic.suggested(
    Keys.suggestedTopicsEntertainment,
    R.strings.suggestedTopics.entertainment,
  ),
  Topic.suggested(
    Keys.suggestedTopicsPolitics,
    R.strings.suggestedTopics.politics,
  ),
  Topic.suggested(
    Keys.suggestedTopicsSports,
    R.strings.suggestedTopics.sports,
  ),
  Topic.suggested(
    Keys.suggestedTopicsHealth,
    R.strings.suggestedTopics.health,
  ),
  Topic.suggested(
    Keys.suggestedTopicsWorld,
    R.strings.suggestedTopics.world,
  ),
  Topic.suggested(
    Keys.suggestedTopicsSustainability,
    R.strings.suggestedTopics.sustainability,
  ),
  Topic.suggested(
    Keys.suggestedTopicsBusiness,
    R.strings.suggestedTopics.business,
  ),
  Topic.suggested(
    Keys.suggestedTopicsLifestyle,
    R.strings.suggestedTopics.lifestyle,
  ),
};
