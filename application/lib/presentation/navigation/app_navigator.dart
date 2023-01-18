import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_screen.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/splash/manager/splash_screen_manager.dart';

@lazySingleton
class AppNavigationManager extends xayn.NavigatorManager {
  AppNavigationManager() : super(pages: PageRegistry.pages);
}

@Injectable(as: SplashScreenNavActions)
class SplashScreenNavActionsImpl extends SplashScreenNavActions {
  final xayn.StackManipulationFunction changeStack;

  SplashScreenNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onSplashScreenAnimationFinished() =>
      changeStack((stack) => stack.replace(PageRegistry.discovery));
}

@Injectable(as: DiscoveryFeedNavActions)
class DiscoveryFeedNavActionsImpl extends DiscoveryFeedNavActions {
  final xayn.StackManipulationFunction changeStack;

  DiscoveryFeedNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onPersonalAreaNavPressed() =>
      changeStack((stack) => stack.replace(PageRegistry.personalArea));
}

@Injectable(as: DiscoveryCardNavActions)
class DiscoveryCardNavActionsImpl extends DiscoveryCardNavActions {
  final xayn.StackManipulationFunction changeStack;

  DiscoveryCardNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onBackNavPressed() => changeStack((stack) => stack.pop());
}

@Injectable(as: BookmarksScreenNavActions)
class BookmarksScreenNavActionsImpl extends BookmarksScreenNavActions {
  final xayn.StackManipulationFunction changeStack;

  BookmarksScreenNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onBackNavPressed() => changeStack((stack) => stack.pop());

  @override
  void onBookmarkPressed({
    required bool isPrimary,
    required UniqueId bookmarkId,
    FeedType? feedType,
  }) =>
      changeStack((stack) => stack.push(PageRegistry.cardDetailsFromDocumentId(
            documentId: bookmarkId,
            feedType: feedType,
          )));
}

@Injectable(as: SettingsNavActions)
class SettingsNavActionsImpl extends SettingsNavActions {
  final xayn.StackManipulationFunction changeStack;

  SettingsNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onBackNavPressed() => changeStack((stack) => stack.pop());
}

@Injectable(as: DiscoveryCardScreenManagerNavActions)
class DiscoveryCardScreenManagerNavActionsImpl
    implements DiscoveryCardScreenManagerNavActions {
  final xayn.StackManipulationFunction changeStack;

  DiscoveryCardScreenManagerNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onBackPressed() => changeStack((stack) => stack.pop());
}

@Injectable(as: ErrorNavActions)
class ErrorNavActionsImpl extends ErrorNavActions {
  final xayn.StackManipulationFunction changeStack;

  ErrorNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void openErrorScreen({String? errorCode, bool replaceCurrentRoute = true}) =>
      changeStack((stack) {
        final page = PageRegistry.error(errorCode);
        if (replaceCurrentRoute) {
          stack.replace(page);
        } else {
          stack.push(page);
        }
      });

  @override
  void onClosePressed() => changeStack((stack) => stack.pop());
}

@Injectable(as: PersonalAreaNavActions)
class NewPersonalAreaNavActionsImpl implements PersonalAreaNavActions {
  final xayn.StackManipulationFunction changeStack;

  NewPersonalAreaNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onHomeNavPressed() =>
      changeStack((stack) => stack.replace(PageRegistry.discovery));

  @override
  void onSettingsNavPressed() =>
      changeStack((stack) => stack.push(PageRegistry.settings));

  @override
  void onCollectionPressed(UniqueId collectionId) =>
      changeStack((stack) => stack.push(PageRegistry.bookmarks(collectionId)));
}
