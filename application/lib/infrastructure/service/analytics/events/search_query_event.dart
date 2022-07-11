import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'searchQuery';
const String _kParamNumberOfResults = 'numberOfResults';

class SearchQueryEvent extends AnalyticsEvent {
  SearchQueryEvent({
    required int numberOfResults,
  }) : super(
          _kEventType,
          properties: {
            _kParamNumberOfResults: numberOfResults,
          },
        );
}
