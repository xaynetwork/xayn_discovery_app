import 'dart:async' show Zone, runZonedGuarded;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';
import 'package:xayn_discovery_app/presentation/app/widget/app.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/widget/select_feature_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

void main() async {
  await setup();
  runZonedGuarded(
    () => runApp(getApp()),
    di.get<BugReportingService>().reportCrash,
  );
}

Future<void> setup() async {
  FlutterError.onError = onError;
  WidgetsFlutterBinding.ensureInitialized();
  final documentsDir = await path.getApplicationDocumentsDirectory();
  final tempDir = await path.getTemporaryDirectory();
  final absoluteAppDir = documentsDir.absolute.path;
  await _maybeClearXaynLegacyData(documents: documentsDir, temp: tempDir);
  final hiveDb = HiveDB.init(absoluteAppDir).catchError(
    /// Some browsers (ie. Firefox) are not allowing the use of IndexedDB
    /// in `Private Mode`, so we need to use Hive in-memory instead
    (_) => HiveDB.init(null),
  );
  await hiveDb;
  await configureDependencies(
    environment:
        EnvironmentHelper.kIsDebug ? debugEnvironment : releaseEnvironment,
  );
  HomeIndicator.hide();
  initServices();
  if (kReleaseMode) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

Future<void> _maybeClearXaynLegacyData(
    {required Directory documents, required Directory temp}) async {
  Future<void> deleteAllFiles(Directory dir) async {
    if (await dir.exists()) {
      logger.i('Deleting all data in ${dir.path}');

      final allFiles = await dir.list().toList();
      for (var file in allFiles) {
        await file.delete(recursive: true);
      }
    }
  }

  final migrationData = await documents
      .list()

      /// This file was used by xayn 2.3.2 or previous versions
      /// so it is a good indicator that the app just upgraded
      .where((element) => element.path.endsWith('migration_info.hive'))
      .toList();

  if (migrationData.isEmpty) {
    logger.i(
        'No Xayn Search Migration data found, app is already migrated, will stop.');
    return;
  }

  await deleteAllFiles(documents);
  await deleteAllFiles(temp);
}

Widget getApp() {
  final initialLinden = R.linden.updateBrightness(
    WidgetsBinding.instance!.window.platformBrightness,
  );
  final unterDenLinden = UnterDenLinden(
    initialLinden: initialLinden,
    onLindenUpdated: R.updateLinden,
    child: const App(),
  );

  return di.get<FeatureManager>().showFeaturesScreen
      ? SelectFeatureScreen(child: unterDenLinden)
      : unterDenLinden;
}

void onError(FlutterErrorDetails details) {
  Zone.current.handleUncaughtError(
    details.exception,
    details.stack ?? StackTrace.empty,
  );
}
