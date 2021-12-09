import 'package:uuid/uuid.dart';

class UniqueId {
  final String value;

  UniqueId() : value = const Uuid().v4();

  const UniqueId.fromTrustedString(String uniqueId) : value = uniqueId;
}
