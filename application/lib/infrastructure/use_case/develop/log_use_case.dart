import 'dart:async';

import 'package:logger/logger.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

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

  /// The logger instance to use
  final Logger logger;

  /// The level to use for the logger
  /// Defaults to [Level.info]
  final Level? level;

  LogUseCase(
    this.builder, {
    required this.logger,
    this.when,
    this.level,
  });

  @override
  Stream<T> transaction(T param) async* {
    final logLevel = level ?? Level.info;
    final predicate = when ?? (_) => true;

    if (predicate(param)) {
      logger.log(
        logLevel,
        builder(param),
      );
    }

    yield param;
  }
}
