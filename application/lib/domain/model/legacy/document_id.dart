import 'package:uuid/uuid.dart';

class DocumentId {
  final String value;

  const DocumentId._(this.value);

  factory DocumentId() => DocumentId._(const Uuid().v4());
  factory DocumentId.fromValue(String value) => DocumentId._(value);
}
