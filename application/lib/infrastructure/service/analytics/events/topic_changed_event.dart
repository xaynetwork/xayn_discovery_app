import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'topicChanged';
const String _kParamOperation = 'operation';
const String _kParamCustom = 'isCustom';

enum TopicChangedEventOperation { addition, removal }

class TopicChangedEvent extends AnalyticsEvent {
  TopicChangedEvent({
    required TopicChangedEventOperation operation,
    bool isCustom = false,
  }) : super(
          _kEventType,
          properties: {
            _kParamOperation: operation.name,
            _kParamCustom: isCustom,
          },
        );
}
