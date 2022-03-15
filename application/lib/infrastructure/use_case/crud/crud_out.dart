import 'package:freezed_annotation/freezed_annotation.dart';

part 'crud_out.freezed.dart';

@freezed
class CrudOut<T> with _$CrudOut<T> {
  const CrudOut._();

  const factory CrudOut.single({
    required T value,
  }) = _Single;

  const factory CrudOut.list({
    required List<T> value,
  }) = _List;
}
