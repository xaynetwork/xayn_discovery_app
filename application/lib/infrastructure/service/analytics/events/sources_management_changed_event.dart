import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'sourcesChanged';
const String _kParamNewTrustedCount = 'newTrustedCount';
const String _kParamOldTrustedCount = 'oldTrustedCount';
const String _kParamNewExcludedCount = 'newExcludedCount';
const String _kParamOldExcludedCount = 'oldExcludedCount';

class SourcesManagementChangedEvent extends AnalyticsEvent {
  SourcesManagementChangedEvent({
    required int newTrustedCount,
    required int oldTrustedCount,
    required int newExcludedCount,
    required int oldExcludedCount,
  }) : super(
          _kEventType,
          properties: {
            _kParamNewTrustedCount: newTrustedCount,
            _kParamOldTrustedCount: oldTrustedCount,
            _kParamNewExcludedCount: newExcludedCount,
            _kParamOldExcludedCount: oldExcludedCount,
          },
        );
}
