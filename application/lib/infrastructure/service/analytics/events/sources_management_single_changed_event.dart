import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/source/manager/sources_manager.dart';

const String _kEventType = 'sourceChanged';
const String _kParamSourceType = 'type';
const String _kParamOperation = 'operation';
const String _kParamBatched = 'isBatched';

enum SourcesManagementSingleChangedEventOperation { addition, removal }

class SourcesManagementSingleChangedEvent extends AnalyticsEvent {
  SourcesManagementSingleChangedEvent({
    required SourceType sourceType,
    required SourcesManagementSingleChangedEventOperation operation,
    bool isBatched = false,
  }) : super(
          _kEventType,
          properties: {
            _kParamSourceType: sourceType.name,
            _kParamOperation: operation.name,
            _kParamBatched: isBatched,
          },
        );
}
