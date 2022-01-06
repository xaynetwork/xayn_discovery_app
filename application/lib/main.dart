import 'dart:async' show Zone, runZonedGuarded;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';
import 'package:xayn_discovery_app/presentation/app/widget/app.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/widget/select_feature_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/log_manager.dart';

late final DiscoveryFeedManager discoveryFeedManager;

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
  final directory = await path.getApplicationDocumentsDirectory();
  final absoluteAppDir = directory.absolute.path;
  final hiveDb = HiveDB.init(absoluteAppDir).catchError(
    /// Some browsers (ie. Firefox) are not allowing the use of IndexedDB
    /// in `Private Mode`, so we need to use Hive in-memory instead
    (_) => HiveDB.init(null),
  );
  await hiveDb;
  configureDependencies();
  di.allowReassignment = true;
  di.get<LogManager>();
  di.get<AnalyticsService>().init();
  // re-register as a sync singleton,
  // because this manager is required sync later on, as the navigation is also sync-based.
  di.registerSingleton<DiscoveryFeedManager>(
      await di.getAsync<DiscoveryFeedManager>());
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

void onError(FlutterErrorDetails details) {
  Zone.current.handleUncaughtError(
    details.exception,
    details.stack ?? StackTrace.empty,
  );
}
