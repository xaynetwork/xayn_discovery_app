import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'entity.freezed.dart';

@freezed
abstract class Entity with _$Entity {
  factory Entity({
    required UniqueId id,
  }) = _Entity;
}
