import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/crud_use_case.dart';

class DbEntityCrudUseCase<T extends DbEntity>
    extends CrudUseCase<DbEntityCrudUseCaseIn<T>, T> {
  final HiveRepository<T> _repository;

  DbEntityCrudUseCase(this._repository);

  @override
  Stream<T> remove(DbEntityCrudUseCaseIn<T> param) async* {
    final entry = _repository.getById(param._id!);

    if (entry != null) {
      _repository.remove(entry);

      yield entry;
    }
  }

  @override
  Stream<T> store(DbEntityCrudUseCaseIn<T> param) async* {
    _repository.save(param._entity!);

    yield param._entity!;
  }

  @override
  Stream<T> watch(DbEntityCrudUseCaseIn<T> param) async* {
    final id = param._id!;

    final startValue = _repository.getById(id);

    var stream = _repository
        .watch(id: id)
        .whereType<ChangedEvent<T>>()
        .map((it) => it.newObject);

    if (startValue != null) {
      stream = stream.startWith(startValue);
    }

    yield* stream;
  }

  @override
  Stream<T> watchAll(DbEntityCrudUseCaseIn<T> param) async* {
    yield* _repository
        .watch()
        .whereType<ChangedEvent<T>>()
        .map((it) => it.newObject)
        .distinct();
  }
}

class DbEntityCrudUseCaseIn<T extends DbEntity> extends CrudUseCaseIn {
  final T? _entity;
  final UniqueId? _id;

  @visibleForTesting
  UniqueId get id => _id ?? _entity!.id;

  const DbEntityCrudUseCaseIn.watch(UniqueId id)
      : _entity = null,
        _id = id,
        super(Operation.watch);

  const DbEntityCrudUseCaseIn.watchAll()
      : _entity = null,
        _id = null,
        super(Operation.watchAll);

  DbEntityCrudUseCaseIn.store(T entity)
      : _entity = entity,
        _id = entity.id,
        super(Operation.store);

  const DbEntityCrudUseCaseIn.remove(UniqueId id)
      : _entity = null,
        _id = id,
        super(Operation.remove);

  @override
  List<Object?> get props => [...super.props, _entity, _id];
}
