import 'package:logger/logger.dart';

final _defaultLogger = Logger();
Logger? _logger;
Logger get logger => _logger ?? _defaultLogger;

/// Initializes a logger which must be used for all application-wide logging needs.
/// [methodCount] is the number of method calls to be displayed
/// [errMethodCount] is the number of method calls if stacktrace is provided
///
/// Check the following link for detailed API reference
/// https://pub.dev/documentation/logger/latest/
void initLogger({
  int methodCount = 0,
  int errMethodCount = 5,
  Level? level,
  LogOutput? output,
  LogFilter? filter,
}) {
  _logger = Logger(
    printer: PrettyPrinter(
      printTime: true,
      printEmojis: true,
      colors: true,
      methodCount: methodCount,
      errorMethodCount: errMethodCount,
    ),
    level: level,
    output: output,
    filter: filter,
  );
}
