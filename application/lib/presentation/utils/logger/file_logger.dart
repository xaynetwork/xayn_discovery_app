import 'dart:developer' as dev;
import 'dart:io';

import 'package:logger/logger.dart';

/// Implementation of [LogOutput].
///
/// It sends everything to the system console and writes to a log [File].
/// The log size is limited to 10MB, if the log exceeds 10MB, then it
/// will first clear the log file, before adding a next entry.
class ConsoleAndFileOutput extends LogOutput {
  final String path;
  final bool logsToFileOnly;
  late final File file;

  ConsoleAndFileOutput(this.path, {this.logsToFileOnly = false}) {
    file = _maybeCreateFile();
  }

  @override
  void output(OutputEvent event) {
    final buffer = StringBuffer();

    for (var it in event.lines) {
      if (!logsToFileOnly) {
        // prints to console on dev builds only
        assert(() {
          dev.log(it);
          return true;
        }());
      }

      buffer.writeln(it);
    }

    _maybeTruncateFile(file);

    file.writeAsStringSync(buffer.toString(), mode: FileMode.append);
  }

  File _maybeCreateFile() {
    final file = File(path);

    if (!file.existsSync()) {
      file.createSync();
    }

    return file;
  }

  void _maybeTruncateFile(File file) {
    // limit the file to 10MB
    final byteLen = file.lengthSync();
    const upperLimit = 1024 * 1024 * 10; // 10MB

    if (byteLen > upperLimit) {
      file.writeAsStringSync('', mode: FileMode.write);
    }
  }
}
