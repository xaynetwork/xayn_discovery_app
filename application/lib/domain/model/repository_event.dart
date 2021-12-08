import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'repository_event.freezed.dart';

abstract class RepositoryEvent<T extends DbEntity> {
  RepositoryEvent();

  abstract final UniqueId id;

  factory RepositoryEvent.from(T? obj, UniqueId id) {
    if (obj == null) {
      return DeletedEvent<T>(id: id);
    } else {
      return ChangedEvent<T>(newObject: obj, id: obj.id);
    }
  }
}

@freezed
class ChangedEvent<T extends DbEntity>
    with _$ChangedEvent<T>
    implements RepositoryEvent<T> {
  factory ChangedEvent({
    required T newObject,
    required UniqueId id,
  }) = _ChangedEvent;
}

@freezed
class DeletedEvent<T extends DbEntity>
    with _$DeletedEvent<T>
    implements RepositoryEvent<T> {
  factory DeletedEvent({
    required UniqueId id,
  }) = _DeletedEvent;
}
