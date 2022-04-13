import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/navigation/page_data.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';

@LazySingleton(as: DeepLinkManager)
class DeepLinkManagerImpl extends DeepLinkManager {
  final xayn.StackManipulationFunction changeStack;

  DeepLinkManagerImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onDeepLink(DeepLinkValue deepLink) {
    final page = deepLink.toPage;
    if (page == null) return;
    changeStack((stack) => stack.push(page));
  }
}

extension on DeepLinkValue {
  UntypedPageData? get toPage {
    switch (this) {
      case DeepLinkValue.activeSearch:
        return PageRegistry.search;
      default:
        return null;
    }
  }
}
