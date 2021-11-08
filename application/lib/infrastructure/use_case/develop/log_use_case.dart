import 'dart:developer';

import 'package:xayn_architecture/xayn_architecture.dart';

typedef LogBuilder<T> = String Function(T data);
typedef LogWhen<T> = bool Function(T data);

class LogUseCase<T> extends UseCase<T, T> {
  final LogBuilder<T> builder;
  final LogWhen<T>? when;

  LogUseCase(this.builder, {this.when});

  @override
  Stream<T> transaction(T param) async* {
    final predicate = when ?? (_) => true;

    if (predicate(param)) {
      log(builder(param));
    }

    yield param;
  }
}
