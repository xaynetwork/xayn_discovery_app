import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'searchNextBatchQuery';
const String _kParamNumberOfResults = 'numberOfResults';

class SearchNextBatchQueryEvent extends AnalyticsEvent {
  SearchNextBatchQueryEvent({
    required int numberOfResults,
  }) : super(
          _kEventType,
          properties: {
            _kParamNumberOfResults: numberOfResults,
          },
        );
}
