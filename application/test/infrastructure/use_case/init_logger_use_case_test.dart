import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/init_logger_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import 'init_logger_use_case_test.mocks.dart';

@GenerateMocks([FileHandler, LoggerHandler])
void main() {
  late MockFileHandler fileHandler;
  late MockLoggerHandler loggerHandler;
  late Directory directory;
  late File file;
  late InitLoggerUseCase initLoggerUseCase;

  setUp(() async {
    fileHandler = MockFileHandler();
    loggerHandler = MockLoggerHandler();
    directory = await Directory.systemTemp.createTemp();
    initLoggerUseCase = InitLoggerUseCase(fileHandler, loggerHandler);
    file = File('${directory.path}/$kLogFileName');
  });

  dynamic _setUpGetAppDirectory() =>
      when(fileHandler.getAppDirectory()).thenAnswer(
        (_) async => directory,
      );

  dynamic _setUpGetAppDirectoryThrowsException() =>
      when(fileHandler.getAppDirectory()).thenAnswer(
        (_) => throw MissingPlatformDirectoryException(''),
      );

  group(
    'Init Logger Use Case',
    () {
      useCaseTest(
        'WHEN getting the app directory throws an Exception THEN dont call initLogger method ',
        setUp: () => _setUpGetAppDirectoryThrowsException(),
        build: () => initLoggerUseCase,
        input: [none],
        verify: (_) => verifyZeroInteractions(loggerHandler),
      );
      useCaseTest(
        'WHEN getting the app directory returns properly THEN initialise the logger with the correct path ',
        setUp: () => _setUpGetAppDirectory(),
        build: () => initLoggerUseCase,
        input: [none],
        verify: (_) => verify(
          loggerHandler.initialiseLogger(file.path),
        ).called(1),
      );

      useCaseTest(
        'WHEN transaction method has been already called THEN dont call the initLogger method ',
        setUp: () => _setUpGetAppDirectory(),
        build: () => initLoggerUseCase,
        act: () {
          initLoggerUseCase.call(none);
          initLoggerUseCase.call(none);
        },
        input: [none],
        verify: (_) => verify(
          loggerHandler.initialiseLogger(file.path),
        ).called(1),
      );
    },
  );
}
