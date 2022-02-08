extension MapExtension on Map<String, dynamic> {
  /// This ensures that unserializable objects like i.e. [UniqueId] can
  /// tracked in services like [AnalyticsService]
  Map<String, String> toSerializableMap() => map(
        (key, value) => MapEntry(key, value.toString()),
      );
}
