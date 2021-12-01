import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager_state.dart';
import 'package:xayn_discovery_app/presentation/feature/widget/select_feature_screen.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';

void main() {
  configureDependencies();
  runApp(getApp());
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xayn Discovery App',
      theme: UnterDenLinden.getLinden(context).themeData,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late FeatureManager featureManager;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    featureManager = di.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureManager, FeatureManagerState>(
        bloc: featureManager,
        builder: (BuildContext context, FeatureManagerState state) {
          final featureMap = state.featureMap;
          if (featureMap[Feature.onBoarding] ?? false) {
            return const OnBoardingScreen();
          }
          return const DiscoveryFeed();
        });
  }
}
