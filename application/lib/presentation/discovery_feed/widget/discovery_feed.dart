import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/widget/base_discovery_widget.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/widget/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class DiscoveryFeed extends BaseDiscoveryWidget<DiscoveryFeedManager> {
  final UniqueId? selectedDocumentId;

  DiscoveryFeed({
    Key? key,
    this.selectedDocumentId,
  }) : super(
          key: key,
          // in `DiscoveryFeedManager` the `didReachEnd` getter is set always
          // to false so the `loadingItemBuilder` will be used to build
          // the widget under documents list
          loadingItemBuilder: (
            BuildContext context,
            double? width,
            double? height,
          ) {
            final state =
                context.findAncestorStateOfType<_DiscoveryFeedState>();

            // return button only if carousel mode is enabled
            if (state?.manager.isCarouselEnabled ?? false) {
              return SizedBox(
                width: width,
                height: height,
                child: Center(
                  child: AppRaisedButton.text(
                    text: R.pocStrings.loadMoreButtonLabel,
                    onPressed: () => state?._manager.onLoadMorePressed(),
                  ),
                ),
              );
            }
            return Container();
          },
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState
    extends BaseDiscoveryFeedState<DiscoveryFeedManager, DiscoveryFeed> {
  late final DiscoveryFeedManager _manager = di.get();

  @override
  DiscoveryFeedManager get manager => _manager;

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
      final card = _manager.state.cards.elementAt(_manager.state.cardIndex);
      final document = card.requireDocument;
      final managers = cardManagersCache.managersOf(document);

      void onBookmarkPressed() =>
          managers.discoveryCardManager.toggleBookmarkDocument(
            document,
            feedType: FeedType.feed,
          );

      void onBookmarkLongPressed() {
        managers.discoveryCardManager.triggerHapticFeedbackMedium();
        managers.discoveryCardManager.onBookmarkLongPressed(
          document,
          feedType: FeedType.feed,
        );
      }

      void onEditReaderModeSettingsPressed() {
        toggleOverlay(
          builder: (_) => EditReaderModeSettingsMenu(
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
              feedType: FeedType.feed,
            ),
          ),
          buildNavBarItemBookmark(
            bookmarkStatus: managers.discoveryCardManager.state.bookmarkStatus,
            onPressed: onBookmarkPressed,
            onLongPressed: onBookmarkLongPressed,
          ),
          buildNavBarItemShare(
              onPressed: () => managers.discoveryCardManager.shareUri(
                    document: document,
                    feedType: FeedType.feed,
                  )),
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
              feedType: FeedType.feed,
            ),
          ),
        ],
        isWidthExpanded: true,
      );
    }

    return _manager.state.isFullScreen ? buildReaderMode() : buildDefault();
  }

  @override
  void initState() {
    manager.checkIfNeedToShowOnboarding();

    // TODO: Replace this PoC code when we have a working solution to fetch a document from the engine by providing an ID
    if (widget.selectedDocumentId != null) {
      final cardIndex = manager.state.cards
          .map((it) => it.document?.documentId.toString())
          .toList()
          .indexOf(widget.selectedDocumentId!.value);
      if (cardIndex == -1) return;
      setState(() {
        cardViewController.index = cardIndex;
        manager.handleIndexChanged(cardIndex);
        manager.maybeSelectCard(widget.selectedDocumentId!);
      });
    }

    super.initState();
  }
}
