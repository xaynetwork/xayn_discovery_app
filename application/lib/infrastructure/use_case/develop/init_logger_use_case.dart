import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import 'handlers.dart';

@singleton
class InitLoggerUseCase extends UseCase<None, None> {
  final FileHandler _fileHandler;
  final LoggerHandler _loggerHandler;
  bool isTransactionDone;

  InitLoggerUseCase(
    this._fileHandler,
    this._loggerHandler,
  ) : isTransactionDone = false;

  @override
  Stream<None> transaction(param) async* {
    try {
      if (isTransactionDone) {
        throw InitLoggerUseCaseException(
            'Transaction method has already been called once');
      }
      final directory = await _fileHandler.getAppDirectory();
      final path = directory.path;

      _loggerHandler.initialiseLogger(
        '$path/$kLogFileName',
      );
    } catch (e) {
      logger.i('Init Logger Use Case: Exception occurred ${e.toString()}');
    } finally {
      if (!isTransactionDone) {
        isTransactionDone = true;
      }
    }
  }
}

class InitLoggerUseCaseException extends Error {
  final String msg;

  InitLoggerUseCaseException(this.msg);

  @override
  String toString() => msg;
}
