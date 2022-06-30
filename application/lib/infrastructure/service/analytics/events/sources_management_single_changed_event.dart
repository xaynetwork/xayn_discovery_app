import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_manager.dart';

const String _kEventType = 'sourceChanged';
const String _kParamSourceType = 'type';
const String _kParamOperation = 'operation';

enum SourcesManagementSingleChangedEventOperation { addition, removal }

class SourcesManagementSingleChangedEvent extends AnalyticsEvent {
  SourcesManagementSingleChangedEvent({
    required SourceType sourceType,
    required SourcesManagementSingleChangedEventOperation operation,
  }) : super(
          _kEventType,
          properties: {
            _kParamSourceType: sourceType.name,
            _kParamOperation: operation.name,
          },
        );
}
