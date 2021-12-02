import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'unique_id.freezed.dart';

@freezed
class UniqueId with _$UniqueId {
  factory UniqueId({
    required String value,
  }) = _UniqueId;

  factory UniqueId.generated() => UniqueId(value: const Uuid().v4());

  factory UniqueId.fromTrustedString(String uniqueId) =>
      UniqueId(value: uniqueId);
}
