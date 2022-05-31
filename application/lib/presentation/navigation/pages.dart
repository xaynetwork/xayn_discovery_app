import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/bookmark/widget/bookmarks_screen.dart';
import 'package:xayn_discovery_app/presentation/deep_search/widget/deep_search.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/screen/discovery_card_screen.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_screen.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/country_feed_settings_page.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/widget/add_source_screen.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/widget/sources_screen.dart';
import 'package:xayn_discovery_app/presentation/payment/paywall_screen.dart';
import 'package:xayn_discovery_app/presentation/personal_area/personal_area_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/splash/widget/splash_screen.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart'
    show DocumentId;

/// IMPORTANT NOTE: do not use `const` keyword with the ScreenWidgets
/// Reason: the `const` word prevent screen from the reloading
/// when the system language changed
class PageRegistry {
  PageRegistry._();

  static const initialRouteKey = "";

  /// Always also add a page to this pages set
  static final Set<xayn.UntypedPageData> pages = {
    splashScreen,
    discovery(),
    search,
    personalArea,
    settings,
    countryFeedSettings,
    payment,
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
  static discovery({
    UniqueId? documentId,
  }) =>
      xayn.PageData(
        name: "discovery",
        arguments: documentId,
        builder: (_, UniqueId? args) => DiscoveryFeed(
          key: discoveryFeedKey,
          selectedDocumentId: args,
        ),
      );

  /// Using a global key prevents rebuilding the [ActiveSearch]
  /// when device orientation changes. This also fixes an issue
  /// with playing videos in full screen mode.
  static final searchKey = GlobalKey();
  static final search = xayn.PageData(
    name: "search",
    //ignore: prefer_const_constructors
    builder: (_, args) => ActiveSearch(
      key: searchKey,
    ),
  );

  /// Using a global key prevents rebuilding the [DeepSearch]
  /// when device orientation changes. This also fixes an issue
  /// with playing videos in full screen mode.
  static final deepSearchKey = GlobalKey();
  static deepSearch({
    required DocumentId documentId,
  }) =>
      xayn.PageData<DeepSearchScreen, DocumentId>(
        name: "deepSearch",
        arguments: documentId,
        //ignore: prefer_const_constructors
        builder: (_, args) => DeepSearchScreen(
          key: searchKey,
          documentId: args!,
        ),
      );

  static cardDetails({
    required UniqueId documentId,
    FeedType? feedType,
  }) =>
      xayn.PageData(
        name: "cardDetails",
        arguments: documentId,
        builder: (_, UniqueId? args) => DiscoveryCardScreen(
          documentId: args!,
          feedType: feedType,
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

  static sourceFeedSettings({bool openOnHiddenSourcesTab = false}) =>
      xayn.PageData(
        name: "sourceFeedSettings",
        arguments: openOnHiddenSourcesTab,
        builder: (_, bool? args) => SourcesScreen(
          openOnHiddenSourcesTab: args!,
        ),
      );

  static final countryFeedSettings = xayn.PageData(
    name: "countryFeedSettings",
    //ignore: prefer_const_constructors
    builder: (_, args) => CountryFeedSettingsPage(),
  );

  static error(String? errorCode) => xayn.PageData(
        name: "error",
        arguments: errorCode,
        //ignore: prefer_const_constructors
        builder: (_, String? args) => SomethingWentWrongErrorScreen(
          errorCode: args,
        ),
      );

  static final payment = xayn.PageData(
    name: "paywall",
    //ignore: prefer_const_constructors
    builder: (_, args) => PaywallScreen(),
  );

  static final excludedSourceSelection = xayn.PageData(
    name: "excludedSourceSelection",
    //ignore: prefer_const_constructors
    builder: (_, args) => AddSourceScreen.excluded(),
  );

  static final trustedSourceSelection = xayn.PageData(
    name: "trustedSourceSelection",
    //ignore: prefer_const_constructors
    builder: (_, args) => AddSourceScreen.trusted(),
  );
}
