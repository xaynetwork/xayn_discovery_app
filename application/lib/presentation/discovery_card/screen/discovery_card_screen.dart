import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_static.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_mixin.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/tts/widget/tts.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
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
    with NavBarConfigMixin, ErrorHandlingMixin {
  late final DiscoveryCardScreenManager _discoveryCardScreenManager =
      di.get(param1: widget.documentId);

  TtsData ttsData = TtsData.disabled();

  @override
  void initState() {
    super.initState();
  }

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
    final cardManagers = di.get<CardManagers>(param1: document);
    final discoveryCardManager = cardManagers.discoveryCardManager;

    return NavBarConfig(
      configIdDiscoveryCardScreen,
      [
        buildNavBarItemArrowLeft(
            onPressed: _discoveryCardScreenManager.onBackPressed),

        /// Like and dislike can not be called because the Document is not related to the feed anymore and will not be updated
        buildNavBarItemShare(
            onPressed: () => discoveryCardManager.shareUri(
                  document: document,
                  feedType: widget.feedType,
                )),
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

  void checkForError(BuildContext context, DiscoveryCardScreenState state) =>
      state.whenOrNull(error: (error) {
        if (error.hasError) {
          openErrorScreen();
        }
        return null;
      });

  Widget _createCard(Document document) {
    final cardManagers = di.get<CardManagers>(param1: document);

    return DiscoveryCardStatic(
      document: document,
      discoveryCardManager: cardManagers.discoveryCardManager,
      imageManager: cardManagers.imageManager,
      onTtsData: (it) =>
          setState(() => ttsData = ttsData.enabled ? TtsData.disabled() : it),
      feedType: widget.feedType,
    );
  }
}
