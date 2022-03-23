import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/crud_out.dart';

abstract class CrudUseCase<In extends CrudUseCaseIn, Out>
    extends UseCase<In, CrudOut<Out?>> {
  @override
  Stream<CrudOut<Out?>> transaction(In param) async* {
    switch (param.operation) {
      case Operation.watch:
        yield* watch(param);
        break;
      case Operation.watchAll:
        yield* watchAll(param);
        break;
      case Operation.store:
        yield* store(param);
        break;
      case Operation.remove:
        yield* remove(param);
        break;
      case Operation.get:
        yield* get(param);
        break;
      case Operation.getAll:
        yield* getAll(param);
        break;
    }
  }

  @protected
  Stream<CrudOut<Out>> getAll(In param);

  @protected
  Stream<CrudOut<Out?>> get(In param);

  @protected
  Stream<CrudOut<Out>> watch(In param);

  @protected
  Stream<CrudOut<Out>> watchAll(In param);

  @protected
  Stream<CrudOut<Out>> store(In param);

  @protected
  Stream<CrudOut<Out>> remove(In param);
}

enum Operation { watch, watchAll, store, remove, get, getAll }

abstract class CrudUseCaseIn extends Equatable {
  const CrudUseCaseIn(this.operation);

  final Operation operation;

  @override
  List<Object?> get props => [operation];
}
