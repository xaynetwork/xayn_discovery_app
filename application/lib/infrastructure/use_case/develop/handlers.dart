import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/file_logger.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

/// This file contains handlers that help to implement proper tests

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

@Injectable()
class LoggerHandler {
  void initialiseLogger(
    String pathToFile,
  ) {
    initLogger(
      output: ConsoleAndFileOutput(
        pathToFile,
      ),
      filter: ProductionFilter(),
    );
  }
}

/// Used for testing properly the generation of a uniqueId for an object.
/// For example, check how it is used in the [CreateCollectionUseCase] and
/// in the corresponding [create_collection_use_case_test.dart] file.
@injectable
class UniqueIdHandler {
  UniqueId generateUniqueId() => UniqueId();
}

/// Used for testing properly the generation of a datetime.
/// For example, check how it is used in the [CreateBookmarkUseCase] and
/// in the corresponding [create_bookmark_use_case_test.dart] file.
@injectable
class DateTimeHandler {
  DateTime getDateTimeNow() => DateTime.now();
}
