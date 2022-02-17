import 'package:system_info2/system_info2.dart';

const String _kCoresEntry = 'cores';
const String _kCoresSocketEntry = 'socket';
const String _kCoresVendorEntry = 'vendor';
const String _kCoresArchEntry = 'arch';
const String _kTimestampEntry = 'timeStamp';

abstract class AnalyticsEvent {
  final String type;
  final Map<String, dynamic> properties;

  AnalyticsEvent(this.type, {Map<String, dynamic>? properties})
      : properties = {
          _kTimestampEntry: DateTime.now().toUtc().toIso8601String(),
          _kCoresEntry: SysInfo.cores
              .map(
                (it) => {
                  _kCoresSocketEntry: it.socket,
                  _kCoresVendorEntry: it.vendor,
                  _kCoresArchEntry: it.architecture.name,
                },
              )
              .toList(growable: false),
        };
}
