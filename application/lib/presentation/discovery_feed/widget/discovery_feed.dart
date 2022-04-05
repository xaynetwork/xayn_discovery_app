import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/widget/base_discovery_widget.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/widget/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_info_card.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class DiscoveryFeed extends BaseDiscoveryWidget<DiscoveryFeedManager> {
  DiscoveryFeed({Key? key})
      : super(
          key: key,
          noItemsBuilder: (
            BuildContext context,
            double? width,
            double? height,
          ) =>
              FeedNoResultsCard(
            width: width,
            height: height,
          ),
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState
    extends BaseDiscoveryFeedState<DiscoveryFeedManager, DiscoveryFeed> {
  late final DiscoveryFeedManager _manager;

  @override
  DiscoveryFeedManager get manager => _manager;

  @override
  void initState() {
    _manager = di.get();

    super.initState();
  }

  @override
  void dispose() {
    _manager.close();

    super.dispose();
  }

  @override
  NavBarConfig get navBarConfig {
    NavBarConfig buildDefault() => NavBarConfig(
          configIdDiscoveryFeed,
          [
            buildNavBarItemHome(
                isActive: true,
                onPressed: () {
                  hideTooltip();
                  _manager.onHomeNavPressed();
                }),
            buildNavBarItemSearch(onPressed: () {
              hideTooltip();
              _manager.onSearchNavPressed();
            }),
            buildNavBarItemPersonalArea(
              onPressed: () {
                hideTooltip();
                _manager.onPersonalAreaNavPressed();
              },
            ),
          ],
        );
    NavBarConfig buildReaderMode() {
      final document =
          _manager.state.results.elementAt(_manager.state.cardIndex);
      final managers = managersOf(document);

      void onBookmarkPressed() =>
          managers.discoveryCardManager.toggleBookmarkDocument(
            document,
            feedType: FeedType.feed,
          );

      void onBookmarkLongPressed() {
        managers.discoveryCardManager.triggerHapticFeedbackMedium();
        showAppBottomSheet(
          context,
          builder: (_) => MoveDocumentToCollectionBottomSheet(
            document: document,
            provider: managers.discoveryCardManager.state.processedDocument
                ?.getProvider(document.resource),
            onError: showTooltip,
            feedType: FeedType.feed,
          ),
        );
      }

      void onEditReaderModeSettingsPressed() {
        toggleOverlay(
          (_) => EditReaderModeSettingsMenu(
            onCloseMenu: removeOverlay,
          ),
        );
        manager.onReaderModeMenuDisplayed(isVisible: isOverlayShown);
      }

      return NavBarConfig(
        configIdDiscoveryFeed,
        [
          buildNavBarItemArrowLeft(onPressed: () async {
            removeOverlay();
            await currentCardController?.animateToClose();
            _manager.handleNavigateOutOfCard(document);
          }),
          buildNavBarItemLike(
            isLiked: managers.discoveryCardManager.state
                .explicitDocumentUserReaction.isRelevant,
            onPressed: () => managers.discoveryCardManager.onFeedback(
              document: document,
              userReaction: managers.discoveryCardManager.state
                      .explicitDocumentUserReaction.isRelevant
                  ? UserReaction.neutral
                  : UserReaction.positive,
            ),
          ),
          buildNavBarItemBookmark(
            isBookmarked: managers.discoveryCardManager.state.isBookmarked,
            onPressed: onBookmarkPressed,
            onLongPressed: onBookmarkLongPressed,
          ),
          buildNavBarItemShare(
              onPressed: () => managers.discoveryCardManager.shareUri(
                    document: document,
                    feedType: FeedType.feed,
                  )),
          if (featureManager.isReaderModeSettingsEnabled)
            buildNavBarItemEditFont(
              onPressed: onEditReaderModeSettingsPressed,
            ),
          buildNavBarItemDisLike(
            isDisLiked: managers.discoveryCardManager.state
                .explicitDocumentUserReaction.isIrrelevant,
            onPressed: () => managers.discoveryCardManager.onFeedback(
              document: document,
              userReaction: managers.discoveryCardManager.state
                      .explicitDocumentUserReaction.isIrrelevant
                  ? UserReaction.neutral
                  : UserReaction.negative,
            ),
          ),
        ],
        isWidthExpanded: true,
      );
    }

    return _manager.state.isFullScreen ? buildReaderMode() : buildDefault();
  }
}
