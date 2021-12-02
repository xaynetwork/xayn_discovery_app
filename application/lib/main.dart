import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/widget/select_feature_screen.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_router.dart';

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
  di.get<AnalyticsService>().init();
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

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  late AppNavigationManager _navigatorManager;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _navigatorManager = di.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: UnterDenLinden.getLinden(context).themeData,
      routeInformationParser: _navigatorManager.routeInformationParser,
      routerDelegate: AppRouter(_navigatorManager),
    );
  }
}
