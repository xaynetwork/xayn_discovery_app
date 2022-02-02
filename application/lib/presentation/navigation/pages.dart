import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/collections/collections_screen.dart';
import 'package:xayn_discovery_app/presentation/bookmark/widget/bookmarks_screen.dart';
import 'package:xayn_discovery_app/presentation/app_loading/widget/app_loading_screen.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/feed_settings_screen.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';
import 'package:xayn_discovery_app/presentation/personal_area/personal_area_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';

class PageRegistry {
  PageRegistry._();

  static const initialRouteKey = "";

  /// Always also add a page to this pages set
  static final Set<xayn.UntypedPageData> pages = {
    appLoading,
    discovery,
    search,
    personalArea,
    settings,
    onboarding,
    feedSettings,
    collections
  };

  // Make sure to add the page names in camel case
  static final appLoading = xayn.PageData(
    name: "appLoading",
    isInitial: true,
    builder: (_, args) => const AppLoadingScreen(),
  );
  static final discovery = xayn.PageData(
    name: "discovery",
    // isInitial: true,
    builder: (_, args) => const DiscoveryFeed(),
  );
  static final search = xayn.PageData(
    name: "search",
    builder: (_, args) => const ActiveSearch(),
  );
  static cardDetails(DiscoveryCardScreenArgs args) => xayn.PageData(
        name: "cardDetails",
        arguments: args,
        builder: (_, DiscoveryCardScreenArgs? args) => DiscoveryCardScreen(
          args: args!,
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
    builder: (_, args) => const PersonalAreaScreen(),
  );
  static final settings = xayn.PageData(
    name: "settings",
    builder: (_, args) => const SettingsScreen(),
  );
  static final onboarding = xayn.PageData(
    name: "onboarding",
    builder: (_, args) => const OnBoardingScreen(),
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
    builder: (_, args) => const FeedSettingsScreen(),
  );

  static final collections = xayn.PageData(
    name: "collections",
    builder: (_, args) => const CollectionsScreen(),
  );
}
