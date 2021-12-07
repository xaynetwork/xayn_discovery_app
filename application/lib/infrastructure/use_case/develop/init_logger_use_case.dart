import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import 'handlers.dart';

@injectable
class InitLoggerUseCase extends UseCase<None, None> {
  final FileHandler _fileHandler;
  final LoggerHandler _loggerHandler;

  InitLoggerUseCase(
    this._fileHandler,
    this._loggerHandler,
  );

  @override
  Stream<None> transaction(param) async* {
    try {
      final directory = await _fileHandler.getAppDirectory();
      final path = directory.path;

      _loggerHandler.initialiseLogger(
        '$path/$kLogFileName',
      );
    } catch (e) {
      logger.i('Init Logger Use Case: Exception occurred ${e.toString()}');
    }
  }
}
