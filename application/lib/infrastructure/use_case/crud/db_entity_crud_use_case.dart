import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/crud_out.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/crud_use_case.dart';

class DbEntityCrudUseCase<T extends DbEntity> extends CrudUseCase<DbCrudIn, T> {
  final HiveRepository<T> _repository;

  DbEntityCrudUseCase(this._repository);

  @override
  Stream<CrudOut<T>> remove(DbCrudIn param) async* {
    final entry = _repository.getById(param._id!);

    if (entry != null) {
      _repository.remove(entry);

      yield CrudOut.single(value: entry);
    }
  }

  @override
  Stream<CrudOut<T>> store(DbCrudIn param) async* {
    _repository.save(param._entity as T);

    yield CrudOut.single(value: param._entity as T);
  }

  @override
  Stream<CrudOut<T>> watch(DbCrudIn param) async* {
    final id = param._id!;

    final startValue = _repository.getById(id);

    var stream = _repository
        .watch(id: id)
        .whereType<ChangedEvent<T>>()
        .map((it) => it.newObject);

    if (startValue != null) {
      stream = stream.startWith(startValue);
    }

    yield* stream.map((event) => CrudOut.single(value: event));
  }

  @override
  Stream<CrudOut<T>> watchAll(DbCrudIn param) async* {
    switch (param.operation) {
      case Operation.watchAll:
        yield* _repository
            .watch()
            .map((it) => it.id)
            .distinct()
            .map((event) => CrudOut.id(id: event));
        break;
      case Operation.watchAllDeleted:
        yield* _repository
            .watch()
            .whereType<DeletedEvent<T>>()
            .map((it) => it.id)
            .distinct()
            .map((event) => CrudOut.id(id: event));
        break;
      case Operation.watchAllChanged:
        yield* _repository
            .watch()
            .whereType<ChangedEvent<T>>()
            .map((it) => it.newObject)
            .distinct()
            .map((event) => CrudOut.single(value: event));
        break;
      default:
        throw "Operation ${param.operation} in watchAll not supported";
    }
  }

  @override
  Stream<CrudOut<T?>> get(DbCrudIn param) async* {
    final id = param._id!;
    yield CrudOut.single(value: _repository.getById(id));
  }

  @override
  Stream<CrudOut<T>> getAll(DbCrudIn param) async* {
    switch (param.operation) {
      case Operation.getAll:
        yield CrudOut.list(value: _repository.getAll());
        break;
      case Operation.getAllContinuously:
        yield* _repository
            .watch()
            .map((_) => _repository.getAll())
            .startWith(_repository.getAll())
            .map((event) => CrudOut.list(value: event))
            .distinct();
        break;
      default:
        throw "Operation ${param.operation} in getAll not supported";
    }
  }
}

class DbCrudIn extends CrudUseCaseIn {
  final DbEntity? _entity;
  final UniqueId? _id;

  @visibleForTesting
  UniqueId get id => _id ?? _entity!.id;

  const DbCrudIn.get(UniqueId id)
      : _entity = null,
        _id = id,
        super(Operation.get);

  const DbCrudIn.getAll()
      : _entity = null,
        _id = null,
        super(Operation.getAll);

  const DbCrudIn.getAllContinuously()
      : _entity = null,
        _id = null,
        super(Operation.getAllContinuously);

  const DbCrudIn.watch(UniqueId id)
      : _entity = null,
        _id = id,
        super(Operation.watch);

  const DbCrudIn.watchAllChanged()
      : _entity = null,
        _id = null,
        super(Operation.watchAllChanged);

  const DbCrudIn.watchAllDeleted()
      : _entity = null,
        _id = null,
        super(Operation.watchAllDeleted);

  const DbCrudIn.watchAll()
      : _entity = null,
        _id = null,
        super(Operation.watchAll);

  DbCrudIn.store(DbEntity entity)
      : _entity = entity,
        _id = entity.id,
        super(Operation.store);

  const DbCrudIn.remove(UniqueId id)
      : _entity = null,
        _id = id,
        super(Operation.remove);

  @override
  List<Object?> get props => [...super.props, _entity, _id];
}
