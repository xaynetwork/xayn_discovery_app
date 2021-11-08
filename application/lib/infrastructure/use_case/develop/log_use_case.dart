import 'dart:async';
import 'dart:developer' as dev;

import 'package:xayn_architecture/concepts/use_case.dart';

/// The log method signature
typedef Log = void Function(
  String message, {
  DateTime? time,
  int? sequenceNumber,
  int level,
  String name,
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
});

/// Log builder definition
typedef LogBuilder<T> = String Function(T data);

/// Log condition definition
typedef LogWhen<T> = bool Function(T data);

/// A [UseCase] which logs its input to the console,
/// and then returns the same input as output.
class LogUseCase<T> extends UseCase<T, T> {
  /// A method which receives the input, and expects a String return value.
  /// This String will be used as the actual log value.
  final LogBuilder<T> builder;

  /// An optional condition, return true if logging applies,
  /// false if you want to skip logging.
  /// If omitted, a log will always take place, for every input value.
  final LogWhen<T>? when;

  /// The handler which will be invoked when logging takes place.
  /// Defaults to [dev.log].
  final Log? log;

  LogUseCase(
    this.builder, {
    this.when,
    this.log,
  });

  @override
  Stream<T> transaction(T param) async* {
    final logHandler = log ?? dev.log;
    final predicate = when ?? (_) => true;

    if (predicate(param)) {
      logHandler(builder(param));
    }

    yield param;
  }
}
