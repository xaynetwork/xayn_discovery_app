import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

abstract class CrudUseCase<In extends CrudUseCaseIn, Out>
    extends UseCase<In, Out> {
  @override
  Stream<Out> transaction(In param) async* {
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
    }
  }

  @protected
  Stream<Out> watch(In param);

  @protected
  Stream<Out> watchAll(In param);

  @protected
  Stream<Out> store(In param);

  @protected
  Stream<Out> remove(In param);
}

enum Operation { watch, watchAll, store, remove }

abstract class CrudUseCaseIn extends Equatable {
  const CrudUseCaseIn(this.operation);

  final Operation operation;

  @override
  List<Object?> get props => [operation];
}
