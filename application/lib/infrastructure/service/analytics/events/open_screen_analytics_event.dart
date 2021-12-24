import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';

const _kArgumentsProperty = 'arguments';

class OpenScreenAnalyticsEvent implements AnalyticsEvent {
  OpenScreenAnalyticsEvent(this.openedScreen)
      : assert(
          openedScreen.settings.name != null,
          'A route with `name = null` has been tracked by analytics navigator observer',
        );

  final Route openedScreen;

  @override
  String get name =>
      'Open ${openedScreen.settings.name!.capitalize(allWords: true)} Screen';

  @override
  Map<String, dynamic>? get properties =>
      openedScreen.settings.arguments == null
          ? null
          : {_kArgumentsProperty: openedScreen.settings.arguments};
}
