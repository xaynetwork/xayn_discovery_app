import 'package:uuid/uuid.dart';

class UniqueId {
  final String value;

  const UniqueId._(this.value);

  factory UniqueId.generated() => UniqueId._(const Uuid().v4());

  factory UniqueId.fromTrustedString(String uniqueId) => UniqueId._(uniqueId);
}
