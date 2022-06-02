import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin CheckValidDocumentMixin<T> on OverlayManagerMixin<T> {
  late final CardManagersCache _cardManagersCache = di.get();
  // late final FeatureManager _featureManager = di.get();

  void checkIfDocumentNotProcessable(
    Document document, {
    bool isDismissible = true,
    VoidCallback? onValid,
    VoidCallback? onClosePressed,
    required CurrentView currentView,
  }) async {
    final discoveryCardManager =
        _cardManagersCache.managersOf(document).discoveryCardManager;

    final processedDocument = await discoveryCardManager.stream
        .map((it) => it.processedDocument)
        .startWith(discoveryCardManager.state.processedDocument)
        .firstWhere((it) => it != null, orElse: () => null);

    if (processedDocument != null) {
      final html = processedDocument.processHtmlResult.contents ?? '';
      final isInvalidHtml = html.trim().isEmpty;
      // TODO after some intensive testing period we should enable gibberish detection to block content,
      // but for now it is better to use the red globe as an indicator
      // final isGibberish = (_featureManager.isGibberishEnabled &&
      //     !discoveryCardManager.state.textIsReadable);
      // if (isInvalidHtml || isGibberish) {
      if (isInvalidHtml) {
        showOverlay(
          OverlayData.bottomSheetReaderModeUnavailableBottomSheet(
            isDismissible: isDismissible,
            onOpenViaBrowser: () => discoveryCardManager.openExternalUrl(
              url: document.resource.url.toString(),
              currentView: currentView,
            ),
            onClosePressed: onClosePressed,
          ),
        );
      } else if (onValid != null) {
        onValid();
      }
    }
  }
}
