abstract class AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? properties;

  const AnalyticsEvent(this.name, {this.properties});
}
