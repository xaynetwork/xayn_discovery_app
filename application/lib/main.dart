import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/utils/hive_db.dart';
import 'package:xayn_discovery_app/presentation/app/widget/app.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/widget/select_feature_screen.dart';

void main() async {
  await setup();
  runApp(getApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await path.getApplicationDocumentsDirectory();
  final absoluteAppDir = directory.absolute.path;
  final hiveDb = HiveDB.init(absoluteAppDir).catchError(
    /// Some browsers (ie. Firefox) are not allowing the use of IndexedDB
    /// in `Private Mode`, so we need to use Hive in-memory instead
    (_) => HiveDB.init(null),
  );
  await hiveDb;
  configureDependencies();
}

Widget getApp() {
  final unterDenLinden = UnterDenLinden(
    initialLinden: R.linden,
    onLindenUpdated: R.updateLinden,
    child: const App(),
  );

  return di.get<FeatureManager>().showFeaturesScreen
      ? SelectFeatureScreen(child: unterDenLinden)
      : unterDenLinden;
}
