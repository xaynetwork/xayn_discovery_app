import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/bookmark/widget/bookmarks_screen.dart';
import 'package:xayn_discovery_app/presentation/collections/collections_screen.dart';
import 'package:xayn_discovery_app/presentation/contact/contact_screen.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/screen/discovery_card_screen.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/feed_settings_screen.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';
import 'package:xayn_discovery_app/presentation/personal_area/personal_area_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/splash/widget/splash_screen.dart';

/// IMPORTANT NOTE: do not use `const` keyword with the ScreenWidgets
/// Reason: the `const` word prevent screen from the reloading
/// when the system language changed
class PageRegistry {
  PageRegistry._();

  static const initialRouteKey = "";

  /// Always also add a page to this pages set
  static final Set<xayn.UntypedPageData> pages = {
    splashScreen,
    discovery,
    search,
    personalArea,
    settings,
    onboarding,
    feedSettings,
    collections
  };

  // Make sure to add the page names in camel case
  static final splashScreen = xayn.PageData(
    name: "splashScreen",
    isInitial: true,
    //ignore: prefer_const_constructors
    builder: (_, args) => SplashScreen(),
  );

  /// Using a global key prevents rebuilding the [DiscoveryFeed]
  /// when device orientation changes. This also fixes an issue
  /// with playing videos in full screen mode.
  static final discoveryFeedKey = GlobalKey();
  static final discovery = xayn.PageData(
    name: "discovery",
    builder: (_, args) => DiscoveryFeed(
      key: discoveryFeedKey,
      manager: di.get(),
    ),
  );

  static final search = xayn.PageData(
    name: "search",
    //ignore: prefer_const_constructors
    builder: (_, args) => ActiveSearch(
      manager: di.get(),
    ),
  );

  static cardDetailsStandalone(DiscoveryCardStandaloneArgs args) =>
      xayn.PageData(
        name: "cardDetailsStandalone",
        arguments: args,
        builder: (_, DiscoveryCardStandaloneArgs? args) =>
            DiscoveryCardStandalone(
          args: args!,
        ),
      );

  static cardDetails(UniqueId documentId) => xayn.PageData(
        name: "cardDetails",
        arguments: documentId,
        builder: (_, UniqueId? args) => DiscoveryCardScreen(
          documentId: args!,
        ),
      );

  static bookmarks(UniqueId collectionId) => xayn.PageData(
        name: "bookmarks",
        arguments: collectionId,
        builder: (_, UniqueId? args) => BookmarksScreen(
          collectionId: args!,
        ),
      );

  static final personalArea = xayn.PageData(
    name: "personalArea",
    //ignore: prefer_const_constructors
    builder: (_, args) => PersonalAreaScreen(),
  );
  static final settings = xayn.PageData(
    name: "settings",
    //ignore: prefer_const_constructors
    builder: (_, args) => SettingsScreen(),
  );

  static final contact = xayn.PageData(
    name: "contact",
    //ignore: prefer_const_constructors
    builder: (_, args) => ContactScreen(),
  );
  static final onboarding = xayn.PageData(
    name: "onboarding",
    //ignore: prefer_const_constructors
    builder: (_, args) => OnBoardingScreen(),
    pageBuilder: (_, widget) => xayn.CustomTransitionPage(
      name: "onboarding",
      child: widget,
      opaque: false,
      transitionsBuilder: (_, a1, a2, widget) => FadeTransition(
        opacity: a1,
        child: widget,
      ),
    ),
  );

  static final feedSettings = xayn.PageData(
    name: "feedSettings",
    //ignore: prefer_const_constructors
    builder: (_, args) => FeedSettingsScreen(),
  );

  static final collections = xayn.PageData(
    name: "collections",
    //ignore: prefer_const_constructors
    builder: (_, args) => CollectionsScreen(),
  );
}
