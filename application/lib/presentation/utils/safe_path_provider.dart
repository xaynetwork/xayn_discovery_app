import 'package:path_provider/path_provider.dart' as path;

Future<String> getAbsoluteApplicationDocumentsDirectory() async {
  final directory = await path.getApplicationDocumentsDirectory();
  return directory.absolute.path;
}
