import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/init_logger_use_case.dart';

@singleton
class LogManager {
  final InitLoggerUseCase _initLoggerUseCase;

  LogManager(
    this._initLoggerUseCase,
  ) {
    _init();
  }

  void _init() => _initLoggerUseCase.call(none);
}
