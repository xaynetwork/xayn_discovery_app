import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';

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
  void onCardDetailsPressed(DiscoveryCardScreenArgs args) =>
      changeStack((stack) => stack.push(PageRegistry.cardDetails(args)));
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
    throw UnimplementedError('Screen not ready yet');
    // changeStack((stack) => stack.push(PageRegistry.collections));
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
