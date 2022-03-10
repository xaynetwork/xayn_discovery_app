import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/widget/base_discovery_widget.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/widget/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// A widget which displays a list of discovery results,
/// and has an ability to perform search.
class ActiveSearch extends BaseDiscoveryWidget<ActiveSearchManager> {
  const ActiveSearch({Key? key, required ActiveSearchManager manager})
      : super(key: key, manager: manager);

  @override
  State<StatefulWidget> createState() => _ActiveSearchState();
}

class _ActiveSearchState
    extends BaseDiscoveryFeedState<ActiveSearchManager, ActiveSearch> {
  @override
  NavBarConfig get navBarConfig {
    NavBarConfig buildDefault() => NavBarConfig(
          [
            buildNavBarItemHome(onPressed: () {
              hideTooltip();
              widget.manager.onHomeNavPressed();
            }),
            buildNavBarItemSearchActive(
              isActive: true,
              onSearchPressed: widget.manager.search,
            ),
            buildNavBarItemPersonalArea(
              onPressed: () {
                hideTooltip();
                widget.manager.onPersonalAreaNavPressed();
              },
            ),
          ],
          showAboveKeyboard: true,
        );
    NavBarConfig buildReaderMode() {
      final document = widget.manager.state.results
          .elementAt(widget.manager.state.cardIndex);
      final managers = managersOf(document);

      void onBookmarkPressed() =>
          managers.discoveryCardManager.toggleBookmarkDocument(document);

      void onBookmarkLongPressed() => showAppBottomSheet(
            context,
            builder: (_) => MoveDocumentToCollectionBottomSheet(
              document: document,
              provider: managers.discoveryCardManager.state.processedDocument
                  ?.getProvider(document.resource),
              onError: (tooltipKey) => showTooltip(tooltipKey),
            ),
          );

      void onEditReaderModeSettingsPressed() => toggleOverlay(
            (_) => EditReaderModeSettingsMenu(
              onCloseMenu: removeOverlay,
            ),
          );

      return NavBarConfig(
        [
          buildNavBarItemArrowLeft(onPressed: () async {
            removeOverlay();
            await currentCardController?.animateToClose();
            widget.manager.handleNavigateOutOfCard();
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
              onPressed: () =>
                  managers.discoveryCardManager.shareUri(document)),
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
        showAboveKeyboard: true,
      );
    }

    return widget.manager.state.isFullScreen
        ? buildReaderMode()
        : buildDefault();
  }
}
