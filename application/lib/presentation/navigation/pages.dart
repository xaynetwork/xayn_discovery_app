import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart' as engine;
import 'package:xayn_discovery_app/presentation/bookmark/widget/bookmarks_screen.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/screen/discovery_card_screen.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_screen.dart';
import 'package:xayn_discovery_app/presentation/personal_area/personal_area_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/splash/widget/splash_screen.dart';

enum PageName {
  splashScreen,
  discovery,
  search,
  personalArea,
  settings,
  countryFeedSettings,
  cardDetails,
  bookmarks,
  sourceFeedSettings,
  error,
  excludedSourceSelection,
  trustedSourceSelection,
}

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
    personalArea,
    settings,
  };

  // Make sure to add the page names in camel case
  static final splashScreen = xayn.PageData(
    name: PageName.splashScreen.name,
    isInitial: true,
    //ignore: prefer_const_constructors
    builder: (_, args) => SplashScreen(),
  );

  /// Using a global key prevents rebuilding the [DiscoveryFeed]
  /// when device orientation changes. This also fixes an issue
  /// with playing videos in full screen mode.
  static final discoveryFeedKey = GlobalKey();
  static final discovery = xayn.PageData(
    name: PageName.discovery.name,
    builder: (_, args) => DiscoveryFeed(
      key: discoveryFeedKey,
    ),
  );

  /// Using a global key prevents rebuilding the [ActiveSearch]
  /// when device orientation changes. This also fixes an issue
  /// with playing videos in full screen mode.
  static final searchKey = GlobalKey();

  static cardDetailsFromDocumentId({
    required UniqueId documentId,
    FeedType? feedType,
  }) =>
      xayn.PageData(
        name: PageName.cardDetails.name,
        arguments: documentId,
        builder: (_, UniqueId? args) => DiscoveryCardScreen.fromDocumentId(
          documentId: args,
          feedType: feedType,
        ),
      );

  static cardDetailsFromDocument({
    required engine.Document document,
    FeedType? feedType,
  }) =>
      xayn.PageData(
        name: PageName.cardDetails.name,
        arguments: document,
        builder: (_, engine.Document? args) => DiscoveryCardScreen.fromDocument(
          document: args,
          feedType: feedType,
        ),
      );

  static bookmarks(UniqueId collectionId) => xayn.PageData(
        name: PageName.bookmarks.name,
        arguments: collectionId,
        builder: (_, UniqueId? args) => BookmarksScreen(
          collectionId: args!,
        ),
      );

  static final personalArea = xayn.PageData(
    name: PageName.personalArea.name,
    //ignore: prefer_const_constructors
    builder: (_, args) => PersonalAreaScreen(),
  );
  static final settings = xayn.PageData(
    name: PageName.settings.name,
    //ignore: prefer_const_constructors
    builder: (_, args) => SettingsScreen(),
  );

  static error(String? errorCode) => xayn.PageData(
        name: PageName.error.name,
        arguments: errorCode,
        //ignore: prefer_const_constructors
        builder: (_, String? args) => SomethingWentWrongErrorScreen(
          errorCode: args,
        ),
      );
}
