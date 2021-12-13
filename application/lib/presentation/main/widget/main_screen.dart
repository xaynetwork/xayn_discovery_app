import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isOnBoardingEnabled = _featureManager.isEnabled(Feature.onBoarding);
    if (isOnBoardingEnabled) return const OnBoardingScreen();
    return const DiscoveryFeed();
  }
}
