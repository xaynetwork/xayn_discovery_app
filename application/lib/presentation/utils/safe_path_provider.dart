import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path;

/// Abstraction over path_provider, because calling path_provider from
/// compiled web code, will throw a RTE.
Future<String> getApplicationDocumentsDirectory() async {
  if (kIsWeb) {
    // not implemented for web
    return '';
  }

  final directory = await path.getApplicationDocumentsDirectory();

  return directory.path;
}

Future<String> getAbsoluteApplicationDocumentsDirectory() async {
  if (kIsWeb) {
    // not implemented for web
    return '';
  }

  final directory = await path.getApplicationDocumentsDirectory();

  return directory.absolute.path;
}
