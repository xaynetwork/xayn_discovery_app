import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';

const _kArgumentsProperty = 'arguments';

class OpenScreenAnalyticsEvent implements AnalyticsEvent {
  OpenScreenAnalyticsEvent(this.screenName, this.arguments);

  final String screenName;
  final dynamic arguments;

  @override
  String get name => 'Open ${screenName.capitalize(allWords: true)} Screen';

  @override
  Map<String, dynamic>? get properties =>
      arguments == null ? null : {_kArgumentsProperty: arguments};
}
