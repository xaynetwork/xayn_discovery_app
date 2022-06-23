import 'package:flat/flat.dart';

extension MapExtension on Map<String, dynamic> {
  /// This ensures that unserializable objects like i.e. [UniqueId] can
  /// tracked in services like [AnalyticsService]
  Map<String, dynamic> toSerializableMap() => flatten(
        map((key, value) {
          final serializableValue = value is Map<String, dynamic>
              ? value.toSerializableMap()
              : value.toString();
          return MapEntry(key, serializableValue);
        }),
      );
}
