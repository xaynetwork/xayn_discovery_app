import 'package:uuid/uuid.dart';

class DocumentId {
  final String value;

  const DocumentId._(this.value);

  factory DocumentId() => DocumentId._(const Uuid().v4());
  factory DocumentId.fromValue(String value) => DocumentId._(value);

  @override
  bool operator ==(Object other) =>
      other is DocumentId ? value == other.value : false;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
