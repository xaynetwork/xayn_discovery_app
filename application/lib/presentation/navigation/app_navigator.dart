import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_screen.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/splash/manager/splash_screen_manager.dart';

@lazySingleton
class AppNavigationManager extends xayn.NavigatorManager {
  final FeatureManager _featureManager;

  AppNavigationManager(this._featureManager) : super(pages: PageRegistry.pages);

  @override
  List<xayn.UntypedPageData> computeInitialPages() => [
        ...super.computeInitialPages(),
        if (_featureManager.showOnboardingScreen) PageRegistry.onboarding,
      ];
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
  void onSearchNavPressed() =>
      changeStack((stack) => stack.replace(PageRegistry.search));

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
  }) =>
      changeStack((stack) => stack.push(PageRegistry.cardDetails(bookmarkId)));
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

@Injectable(as: FeedSettingsNavActions)
class FeedSettingsNavActionsImpl extends FeedSettingsNavActions {
  final xayn.StackManipulationFunction changeStack;

  FeedSettingsNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onBackNavPressed() => changeStack((stack) => stack.pop());
}

@Injectable(as: CollectionsScreenNavActions)
class CollectionsScreenNavActionsImpl extends CollectionsScreenNavActions {
  final xayn.StackManipulationFunction changeStack;

  CollectionsScreenNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onBackNavPressed() => changeStack((stack) => stack.pop());

  @override
  void onCollectionPressed(UniqueId collectionId) =>
      changeStack((stack) => stack.push(PageRegistry.bookmarks(collectionId)));
}

@Injectable(as: ActiveSearchNavActions)
class ActiveSearchNavActionsImpl implements ActiveSearchNavActions {
  final xayn.StackManipulationFunction changeStack;

  ActiveSearchNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onHomeNavPressed() =>
      changeStack((stack) => stack.replace(PageRegistry.discovery));

  @override
  void onPersonalAreaNavPressed() =>
      changeStack((stack) => stack.replace(PageRegistry.personalArea));

  @override
  void onCardDetailsPressed(DiscoveryCardStandaloneArgs args) => changeStack(
      (stack) => stack.push(PageRegistry.cardDetailsStandalone(args)));
}

@Injectable(as: PersonalAreaNavActions)
class PersonalAreaNavActionsImpl implements PersonalAreaNavActions {
  final xayn.StackManipulationFunction changeStack;

  PersonalAreaNavActionsImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onHomeNavPressed() =>
      changeStack((stack) => stack.replace(PageRegistry.discovery));

  @override
  void onActiveSearchNavPressed() =>
      changeStack((stack) => stack.replace(PageRegistry.search));

  @override
  void onCollectionsNavPressed() {
    changeStack((stack) => stack.push(PageRegistry.collections));
  }

  @override
  void onHomeFeedSettingsNavPressed() {
    changeStack((stack) => stack.push(PageRegistry.feedSettings));
  }

  @override
  void onSettingsNavPressed() =>
      changeStack((stack) => stack.push(PageRegistry.settings));
}

@Injectable(as: OnBoardingNavActions)
class Impl implements OnBoardingNavActions {
  final xayn.StackManipulationFunction changeStack;

  Impl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onClosePressed() => changeStack((stack) => stack.pop());
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
  void openErrorScreen() =>
      changeStack((stack) => stack.replace(PageRegistry.error));

  @override
  void onClosePressed() => changeStack((stack) => stack.pop());
}
