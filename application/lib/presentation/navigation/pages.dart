import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';

class PageRegistry {
  PageRegistry._();

  static const initialRouteKey = "";

  /// Always also add a page to this pages set
  static final Set<xayn.UntypedPageData> pages = {
    discovery,
    search,
    account,
    onboarding,
  };

  static final discoveryFeedManager = di.getAsync<DiscoveryFeedManager>();
  static final discovery = xayn.PageData(
    name: "discovery",
    isInitial: true,
    builder: (_, args) => FutureBuilder<DiscoveryFeedManager>(
      future: discoveryFeedManager,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        return DiscoveryFeed(
          manager: snapshot.requireData,
        );
      },
    ),
  );
  static final search = xayn.PageData(
    name: "search",
    builder: (_, args) => const ActiveSearch(),
  );
  static final account = xayn.PageData(
    name: "account",
    builder: (_, args) => const SettingsScreen(),
  );
  static final onboarding = xayn.PageData(
    name: "onboarding",
    builder: (_, args) => const OnBoardingScreen(),
    pageBuilder: (_, widget) => xayn.CustomTransitionPage(
      child: widget,
      opaque: false,
      transitionsBuilder: (_, a1, a2, widget) => FadeTransition(
        opacity: a1,
        child: widget,
      ),
    ),
  );
}
