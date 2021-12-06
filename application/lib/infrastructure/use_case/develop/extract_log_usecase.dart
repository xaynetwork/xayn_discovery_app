import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

@injectable
class ExtractLogUseCase extends UseCase<None, ExtractLogUseCaseResult> {
  final FileHandler _fileHandler;
  final ShareHandler _shareHandler;

  ExtractLogUseCase(
    this._fileHandler,
    this._shareHandler,
  );

  @override
  Stream<ExtractLogUseCaseResult> transaction(param) async* {
    try {
      final directory = await _fileHandler.getAppDirectory();
      final file = _fileHandler.createFileObject(
        fileName: kLogFileName,
        path: directory.path,
      );
      final exists = await _fileHandler.exists(file);

      if (exists) {
        final log = _fileHandler.readAsStringSync(file);

        if (log.isNotEmpty) {
          await _shareHandler.shareFiles([file.path]);
          logger.i('Extract Log UseCase: Share dialog opened ');
          yield ExtractLogUseCaseResult.shareDialogOpened;
        }
      } else {
        logger.i('Extract Log Use Case: Log file doesn\'t exist');
        yield ExtractLogUseCaseResult.fileNotExisting;
      }
    } catch (e) {
      logger.i('Extract Log Use Case: Exception occurred ${e.toString()}');
      yield ExtractLogUseCaseResult.exceptionOccurred;
    }
  }
}

enum ExtractLogUseCaseResult {
  shareDialogOpened,
  exceptionOccurred,
  fileNotExisting,
}

@Injectable()
class FileHandler {
  FileHandler();

  /// Throws a [MissingPlatformDirectoryException] if the system is unable to provide the directory.
  Future<Directory> getAppDirectory() => getApplicationDocumentsDirectory();

  File createFileObject({
    required String fileName,
    required String path,
  }) =>
      File('$path/$fileName');

  Future<bool> exists(File file) => file.exists();

  /// Throws a [FileSystemException] if the operation fails.
  String readAsStringSync(
    File file, {
    Encoding encoding = utf8,
  }) =>
      file.readAsStringSync(
        encoding: encoding,
      );
}

@Injectable()
class ShareHandler {
  Future<void> shareFiles(List<String> paths) => Share.shareFiles(paths);
}
