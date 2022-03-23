import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'crud_out.freezed.dart';

@freezed
class CrudOut<T> with _$CrudOut<T> {
  const CrudOut._();
  const factory CrudOut.id({
    required UniqueId id,
  }) = _Id;

  const factory CrudOut.single({
    required T value,
  }) = _Single;

  const factory CrudOut.list({
    required List<T> value,
  }) = _List;
}
