import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

mixin CheckValidDocumentMixin<T> on OverlayManagerMixin<T> {
  late final CardManagersCache _cardManagersCache = di.get();

  // late final FeatureManager _featureManager = di.get();

  void checkIfDocumentNotProcessable(
    Document document, {
    bool isDismissible = true,
    VoidCallback? onValid,
    VoidCallback? onClosePressed,
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
      final isGibberish = !discoveryCardManager.state.textIsReadable;
      if (isInvalidHtml || isGibberish) {
        showOverlay(
          OverlayData.bottomSheetReaderModeUnavailableBottomSheet(
            isDismissible: isDismissible,
            onOpenViaBrowser: () => discoveryCardManager.openExternalUrl(
                url: document.resource.url.toString()),
            onClosePressed: onClosePressed,
          ),
        );
      } else if (onValid != null) {
        onValid();
      }
    }
  }
}
