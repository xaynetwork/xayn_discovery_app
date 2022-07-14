import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'resetAIAction';
const String _kParamAction = 'action';

enum ResetAIActionValueEnum {
  reset,
  cancel,
}

class ResetAIActionEvent extends AnalyticsEvent {
  ResetAIActionEvent({
    required ResetAIActionValueEnum action,
  }) : super(
          _kEventType,
          properties: {
            _kParamAction: action.name,
          },
        );
}
