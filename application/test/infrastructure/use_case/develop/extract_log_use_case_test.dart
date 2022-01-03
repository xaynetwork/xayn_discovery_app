import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

@GenerateMocks([FileHandler, ShareHandler])
void main() {
  late MockFileHandler fileHandler;
  late MockShareHandler shareHandler;
  late Directory directory;
  late File file;

  setUp(() async {
    fileHandler = MockFileHandler();
    shareHandler = MockShareHandler();
    directory = await Directory.systemTemp.createTemp();
    file = File('${directory.path}/$kLogFileName');
  });

  dynamic _setUpGetAppDirectoryThrowsException() =>
      when(fileHandler.getAppDirectory()).thenAnswer(
        (_) => throw MissingPlatformDirectoryException(''),
      );

  dynamic _setUpGetAppDirectory() =>
      when(fileHandler.getAppDirectory()).thenAnswer(
        (_) async => directory,
      );

  dynamic _setUpCreateFileObject() => when(
        fileHandler.createFileObject(
          fileName: kLogFileName,
          path: directory.path,
        ),
      ).thenReturn(file);

  dynamic _setUpFileExistsReturnFalse() =>
      when(fileHandler.exists(file)).thenAnswer(
        (_) async => false,
      );

  dynamic _setUpFileExistsReturnTrue() =>
      when(fileHandler.exists(file)).thenAnswer(
        (_) async => true,
      );

  dynamic _setUpFileReadAsStringSync() =>
      when(fileHandler.readAsStringSync(file)).thenReturn('log');

  dynamic _setUpFileReadAsStringSyncThrowsException() =>
      when(fileHandler.readAsStringSync(file))
          .thenAnswer((_) => throw FileSystemException);

  group('Extract Log Use Case', () {
    useCaseTest(
      'WHEN getting the app directory throws an Exception THEN dont show the share dialog ',
      setUp: () => _setUpGetAppDirectoryThrowsException(),
      build: () => ExtractLogUseCase(fileHandler, shareHandler),
      input: [none],
      verify: (_) => verifyZeroInteractions(shareHandler),
      expect: [useCaseSuccess(ExtractLogUseCaseResult.exceptionOccurred)],
    );

    useCaseTest(
      'WHEN log file doesnt exist THEN dont show the share dialog  ',
      setUp: () async {
        _setUpGetAppDirectory();
        _setUpCreateFileObject();
        _setUpFileExistsReturnFalse();
      },
      build: () => ExtractLogUseCase(fileHandler, shareHandler),
      input: [none],
      verify: (_) => verifyZeroInteractions(shareHandler),
      expect: [useCaseSuccess(ExtractLogUseCaseResult.fileNotExisting)],
    );

    useCaseTest(
      'WHEN reading log file throws Exception THEN dont show the share dialog  ',
      setUp: () async {
        _setUpGetAppDirectory();
        _setUpCreateFileObject();
        _setUpFileExistsReturnTrue();
        _setUpFileReadAsStringSyncThrowsException();
      },
      build: () => ExtractLogUseCase(fileHandler, shareHandler),
      input: [none],
      verify: (_) => verifyZeroInteractions(shareHandler),
      expect: [useCaseSuccess(ExtractLogUseCaseResult.exceptionOccurred)],
    );

    useCaseTest(
      'WHEN log file is not empty THEN show the share dialog  ',
      setUp: () async {
        _setUpGetAppDirectory();
        _setUpCreateFileObject();
        _setUpFileExistsReturnTrue();
        _setUpFileReadAsStringSync();
      },
      build: () => ExtractLogUseCase(fileHandler, shareHandler),
      input: [none],
      verify: (_) => verify(shareHandler.shareFiles([file.path])).called(1),
      expect: [useCaseSuccess(ExtractLogUseCaseResult.shareDialogOpened)],
    );
  });
}
