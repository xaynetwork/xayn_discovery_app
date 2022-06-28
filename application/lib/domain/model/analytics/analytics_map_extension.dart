import 'package:flat/flat.dart';

extension AnalyticsMapExtension on Map<String, dynamic> {
  /// This ensures that unserializable objects like i.e. [UniqueId] can
  /// tracked in services like [AnalyticsService]
  Map<String, dynamic> toAnalyticsMap() => flatten(
        map((key, value) {
          final serializableValue = value is Map<String, dynamic>
              ? value.toAnalyticsMap()
              : value.toString();
          return MapEntry(key, serializableValue);
        }),
      );
}
