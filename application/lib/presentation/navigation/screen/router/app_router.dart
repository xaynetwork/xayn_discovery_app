import 'package:auto_route/auto_route.dart';
import 'package:xayn_discovery_app/main.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';

@CupertinoAutoRouter(
  routes: <AutoRoute>[
    CupertinoRoute(page: MainScreen, initial: true),
    CupertinoRoute(page: DiscoveryFeed),
    CupertinoRoute(page: SettingsScreen),
    CupertinoRoute(page: ActiveSearch),
    CustomRoute(page: OnBoardingScreen, opaque: false),
  ],
)
class $AppRouter {}
