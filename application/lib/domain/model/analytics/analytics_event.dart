import 'package:flutter/foundation.dart';

@immutable
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;

  const AnalyticsEvent(this.name, {this.properties = const {}});
}
