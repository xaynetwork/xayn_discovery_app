import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/navigation/page_data.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';

enum DeepLinkValue {
  none,
  activeSearch,
  cardDetailsFromDocument,
}

abstract class DeepLinkManager {
  void onDeepLink(DeepLinkData deepLinkData);
}

@LazySingleton(as: DeepLinkManager)
class DeepLinkManagerImpl extends DeepLinkManager {
  final AppNavigationManager manager;

  DeepLinkManagerImpl(this.manager);

  @override
  void onDeepLink(DeepLinkData deepLinkData) {
    // ignore: invalid_use_of_protected_member
    final xayn.StackManipulationFunction changeStack = manager.manipulateStack;

    final page = deepLinkData.toPage;
    if (page == null) return;
    changeStack(
      (stack) => deepLinkData.when(
        none: () => stack.replace(page),
        activeSearch: () => stack.replace(page),
        feed: (_) => stack.push(page),
        cardDetails: (_) => stack.push(page),
      ),
    );

    // if (page.name == PageName.cardDetails.name) {
    //   /// If the app is being opened, first replace the splash screen with the feed screen
    //   if (manager.state.pages.last.name == PageName.splashScreen.name) {
    //     changeStack((stack) => stack.replace(PageRegistry.discovery()));
    //   }
    //   changeStack((stack) => stack.push(page));
    // } else {
    //   changeStack((stack) => stack.replace(page));
    // }
  }
}

extension on DeepLinkData {
  UntypedPageData? get toPage {
    return when(
      none: () => null,
      activeSearch: () => PageRegistry.search,
      feed: (documentId) =>
          PageRegistry.cardDetailsFromDocumentId(documentId: documentId),
      cardDetails: (document) =>
          PageRegistry.cardDetailsFromDocument(document: document),
    );
  }
}
