import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/navigation/page_data.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';

enum DeepLinkValue {
  none,
  activeSearch,
}

abstract class DeepLinkManager {
  void onDeepLink(DeepLinkData deepLinkData);
}

@LazySingleton(as: DeepLinkManager)
class DeepLinkManagerImpl extends DeepLinkManager {
  final xayn.StackManipulationFunction changeStack;

  DeepLinkManagerImpl(AppNavigationManager manager)
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      : changeStack = manager.manipulateStack;

  @override
  void onDeepLink(DeepLinkData deepLinkData) {
    final page = deepLinkData.toPage;
    if (page == null) return;
    changeStack((stack) => stack.replace(page));
  }
}

extension on DeepLinkData {
  UntypedPageData? get toPage {
    return when(
      none: () => null,
      activeSearch: () => PageRegistry.search,
      feed: (documentId) => PageRegistry.discovery(documentId: documentId),
    );
  }
}
