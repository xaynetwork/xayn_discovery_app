import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/widget/reader_mode_unavailable_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_static.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/widget/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/tts/widget/tts.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

/// Implementation of [DiscoveryCardBase] which can be used as a navigation endpoint.
class DiscoveryCardScreen extends StatefulWidget {
  const DiscoveryCardScreen({
    Key? key,
    required this.documentId,
    this.feedType,
  }) : super(key: key);

  final UniqueId documentId;
  final FeedType? feedType;

  @override
  State<DiscoveryCardScreen> createState() => _DiscoveryCardScreenState();
}

class _DiscoveryCardScreenState extends State<DiscoveryCardScreen>
    with
        NavBarConfigMixin,
        ErrorHandlingMixin,
        TooltipStateMixin,
        OverlayStateMixin {
  late final DiscoveryCardScreenManager _discoveryCardScreenManager =
      di.get(param1: widget.documentId);
  late final FeatureManager featureManager = di.get();
  late final CardManagersCache _cardManagersCache = di.get();

  TtsData ttsData = TtsData.disabled();

  @override
  NavBarConfig get navBarConfig => _discoveryCardScreenManager.state.map(
        initial: (_) => NavBarConfig.backBtn(
          buildNavBarItemBack(
              onPressed: _discoveryCardScreenManager.onBackPressed),
        ),
        populated: (p) => _createDocumentNavbar(p.document),
        error: (_) => NavBarConfig.backBtn(
          buildNavBarItemBack(
              onPressed: _discoveryCardScreenManager.onBackPressed),
        ),
      );

  NavBarConfig _createDocumentNavbar(Document document) {
    final discoveryCardManager =
        _cardManagersCache.managersOf(document).discoveryCardManager;

    void onBookmarkPressed() => discoveryCardManager.toggleBookmarkDocument(
          document,
        );

    void onBookmarkLongPressed() => showAppBottomSheet(
          context,
          builder: (_) => MoveDocumentToCollectionBottomSheet(
            document: document,
            provider: discoveryCardManager.state.processedDocument
                ?.getProvider(document.resource),
            onError: showTooltip,
          ),
        );

    return NavBarConfig(
      configIdDiscoveryCardScreen,
      [
        buildNavBarItemArrowLeft(
            onPressed: _discoveryCardScreenManager.onBackPressed),

        buildNavBarItemBookmark(
          bookmarkStatus: discoveryCardManager.state.bookmarkStatus,
          onPressed: onBookmarkPressed,
          onLongPressed: onBookmarkLongPressed,
        ),

        /// Like and dislike can not be called because the Document is not related to the feed anymore and will not be updated
        buildNavBarItemShare(
          onPressed: () => discoveryCardManager.shareUri(
            document: document,
            feedType: widget.feedType,
          ),
        ),

        if (featureManager.isReaderModeSettingsEnabled)
          buildNavBarItemEditFont(
            onPressed: onEditReaderModeSettingsPressed,
          ),
      ],
      isWidthExpanded: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      body: Tts(
        data: ttsData,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: BlocConsumer<DiscoveryCardScreenManager,
              DiscoveryCardScreenState>(
            listener: checkForError,
            builder: (context, state) => state.map(
              populated: (v) => _createCard(v.document),
              initial: (_) => Container(),
              error: (_) => Container(),
            ),
            bloc: _discoveryCardScreenManager,
          ),
        ),
      ),
    );
  }

  void checkForError(BuildContext context, DiscoveryCardScreenState state) {
    state.whenOrNull(
        populated: _checkIfDocumentNotProcessable,
        error: (error) {
          if (error.hasError) {
            openErrorScreen();
          }
          return null;
        });
  }

  Widget _createCard(Document document) {
    final cardManagers = _cardManagersCache.managersOf(document);

    return DiscoveryCardStatic(
      document: document,
      discoveryCardManager: cardManagers.discoveryCardManager,
      imageManager: cardManagers.imageManager,
      onTtsData: (it) =>
          setState(() => ttsData = ttsData.enabled ? TtsData.disabled() : it),
      feedType: widget.feedType,
    );
  }

  void onEditReaderModeSettingsPressed() {
    toggleOverlay(
      (_) => EditReaderModeSettingsMenu(
        onCloseMenu: removeOverlay,
      ),
    );
    _discoveryCardScreenManager.onReaderModeMenuDisplayed(
      isVisible: isOverlayShown,
    );
  }

  void _checkIfDocumentNotProcessable(Document document) async {
    final discoveryCardManager =
        di.get<CardManagers>(param1: document).discoveryCardManager;
    final processedDocument = await discoveryCardManager.stream
        .map((it) => it.processedDocument)
        .startWith(discoveryCardManager.state.processedDocument)
        .firstWhere((it) => it != null, orElse: () => null);

    if (mounted && processedDocument != null) {
      final html = processedDocument.processHtmlResult.contents ?? '';
      final isInvalidHtml = html.trim().isEmpty;
      if (isInvalidHtml) {
        final unavailableBottomSheet = ReaderModeUnavailableBottomSheet(
          onOpenViaBrowser: () => discoveryCardManager.openExternalUrl(
            url: document.resource.url.toString(),
            currentView: CurrentView.bookmark,
          ),
          onClosePressed: _discoveryCardScreenManager.onBackPressed,
        );

        showAppBottomSheet(
          context,
          builder: (_) => unavailableBottomSheet,
          allowStacking: false,
          isDismissible: false,
        );
      }
    }
  }
}
