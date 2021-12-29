import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/init_logger_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/log_manager.dart';

import 'fakes.dart';

@Injectable(as: InvokeApiEndpointUseCase)
class TestBingClient extends InvokeApiEndpointUseCase {
  @override
  Stream<ApiEndpointResponse> transaction(Uri param) {
    return Stream.value(ApiEndpointResponse.complete([fakeDocument]));
  }
}

@Injectable(as: ConnectivityUriUseCase)
class AlwaysConnectedConnectivityUseCase extends ConnectivityUriUseCase {
  @override
  Stream<Uri> transaction(Uri param) {
    return Stream.value(param);
  }
}

@Singleton(as: InitLoggerUseCase)
class JustLogToConsoleUseCase extends InitLoggerUseCase {
  JustLogToConsoleUseCase(FileHandler fileHandler, LoggerHandler loggerHandler)
      : super(fileHandler, loggerHandler);

  @override
  Stream<None> transaction(param) async* {
    initLogger(output: ConsoleOutput());
  }
}

@Singleton(as: LogManager)
class TestLogManager extends LogManager {
  TestLogManager(InitLoggerUseCase initLoggerUseCase)
      : super(initLoggerUseCase);
}
