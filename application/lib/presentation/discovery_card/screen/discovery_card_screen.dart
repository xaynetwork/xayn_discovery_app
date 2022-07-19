import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_static.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/widget/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/tts/widget/tts.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_mixin.dart';
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

const _discoveryCardNavBarConfigId =
    NavBarConfigId('discoveryCardNavBarConfigId');

class _DiscoveryCardScreenState extends State<DiscoveryCardScreen>
    with
        NavBarConfigMixin,
        OverlayMixin<DiscoveryCardScreen>,
        OverlayStateMixin<DiscoveryCardScreen> {
  late final DiscoveryCardScreenManager _discoveryCardScreenManager =
      di.get(param1: widget.documentId);
  late final CardManagersCache _cardManagersCache = di.get();

  TtsData ttsData = TtsData.disabled();

  @override
  OverlayManager get overlayManager =>
      _discoveryCardScreenManager.overlayManager;

  @override
  NavBarConfig get navBarConfig => _discoveryCardScreenManager.state.map(
        initial: (_) => NavBarConfig.backBtn(
          _discoveryCardNavBarConfigId,
          buildNavBarItemBack(
              onPressed: _discoveryCardScreenManager.onBackPressed),
        ),
        populated: (p) => _createDocumentNavbar(p.document),
      );

  NavBarConfig _createDocumentNavbar(Document document) {
    final discoveryCardManager =
        _cardManagersCache.managersOf(document).discoveryCardManager;

    void onBookmarkPressed() => discoveryCardManager.toggleBookmarkDocument(
          document,
        );

    void onBookmarkLongPressed() =>
        discoveryCardManager.onBookmarkLongPressed(document);

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
          child:
              BlocBuilder<DiscoveryCardScreenManager, DiscoveryCardScreenState>(
            builder: (context, state) => state.map(
              populated: (v) => _createCard(v.document),
              initial: (_) => Container(),
            ),
            bloc: _discoveryCardScreenManager,
          ),
        ),
      ),
    );
  }

  Widget _createCard(Document document) => DiscoveryCardStatic(
        document: document,
        onTtsData: (it) =>
            setState(() => ttsData = ttsData.enabled ? TtsData.disabled() : it),
        feedType: widget.feedType,
      );

  void onEditReaderModeSettingsPressed() {
    toggleOverlay(
      builder: (_) => EditReaderModeSettingsMenu(
        onCloseMenu: removeOverlay,
      ),
    );
    _discoveryCardScreenManager.onReaderModeMenuDisplayed(
      isVisible: isOverlayShown,
    );
  }
}
