import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'af_interaction';
const String _kParamInteraction = 'interaction';

class InteractionMarketingEvent extends AnalyticsEvent {
  InteractionMarketingEvent({
    required UserReaction interaction,
  }) : super(
          _kEventType,
          properties: {
            _kParamInteraction: interaction.name,
          },
        );
}
