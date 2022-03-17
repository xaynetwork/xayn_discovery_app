import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/presentation/utils/map_utils.dart';

const String _kTimestampEntry = 'timeStamp';
const String _kDay = 'dayOfWeek';
const String _defaultLocale = 'en_US';

abstract class AnalyticsEvent {
  final String type;
  final Map<String, dynamic> properties;

  AnalyticsEvent(this.type, {Map<String, dynamic>? properties})
      : properties = {
          _kTimestampEntry: DateTime.now().toUtc().toIso8601String(),
          _kDay: DateFormat.EEEE(_defaultLocale).format(DateTime.now()),
          if (properties != null) ...properties,
        }.toSerializableMap();
}
