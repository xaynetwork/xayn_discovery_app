import 'package:xayn_discovery_app/presentation/utils/map_utils.dart';

const String _kTimestampEntry = 'timeStamp';

abstract class AnalyticsEvent {
  final String type;
  final Map<String, dynamic> properties;

  AnalyticsEvent(this.type, {Map<String, dynamic>? properties})
      : properties = {
          _kTimestampEntry: DateTime.now().toUtc().toIso8601String(),
          if (properties != null) ...properties,
        }.toSerializableMap();
}
