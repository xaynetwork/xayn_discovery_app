import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
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
    final materialApp = MaterialApp(
      title: 'Xayn Discovery App',
      theme: UnterDenLinden.getLinden(context).themeData,
      navigatorObservers: [
        NavBarObserver(),
      ],
      home: const MainScreen(),
    );

    final stack = Stack(
      children: [
        materialApp,
        const Positioned.fill(top: null, child: NavBar()),
      ],
    );
    // this one used to style properly NavBar components
    // it should be the same as your App class
    return MaterialApp(
      home: NavBarContainer(child: stack),
      theme: materialApp.theme,
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
  late FeatureManager _featureManager;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    _featureManager = di.get();
    if (_featureManager.isEnabled(Feature.onBoarding)) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
        );
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const DiscoveryFeed();
  }
}
