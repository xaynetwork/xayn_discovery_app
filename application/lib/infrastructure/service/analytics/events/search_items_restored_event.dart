import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'searchItemsRestored';
const String _kParamNumberOfResults = 'numberOfResults';

class SearchItemsRestoredEvent extends AnalyticsEvent {
  SearchItemsRestoredEvent({
    required int numberOfResults,
  }) : super(
          _kEventType,
          properties: {
            _kParamNumberOfResults: numberOfResults,
          },
        );
}
