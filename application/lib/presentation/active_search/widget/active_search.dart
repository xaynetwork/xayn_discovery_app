import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/widget/base_discovery_widget.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/widget/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_info_card.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// A widget which displays a list of discovery results,
/// and has an ability to perform search.
class ActiveSearch extends BaseDiscoveryWidget<ActiveSearchManager> {
  ActiveSearch({Key? key})
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
          finalItemBuilder: (
            BuildContext context,
            double? width,
            double? height,
          ) =>
              FeedEndOfResultsCard(
            width: width,
            height: height,
          ),
        );

  @override
  State<StatefulWidget> createState() => _ActiveSearchState();
}

class _ActiveSearchState
    extends BaseDiscoveryFeedState<ActiveSearchManager, ActiveSearch> {
  late final ActiveSearchManager _manager;

  @override
  ActiveSearchManager get manager => _manager;

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
          configIdSearch,
          [
            buildNavBarItemHome(onPressed: () {
              hideTooltip();
              _manager.onHomeNavPressed();
            }),
            buildNavBarItemSearchActive(
              isActive: true,
              autofocus: _manager.state.results.isEmpty,
              hint: _manager.lastUsedSearchTerm,
              initialText: _manager.state.results.isNotEmpty
                  ? _manager.lastUsedSearchTerm
                  : null,
              onSearchPressed: _manager.handleSearchTerm,
            ),
            buildNavBarItemPersonalArea(
              onPressed: () {
                hideTooltip();
                _manager.onPersonalAreaNavPressed();
              },
            ),
          ],
          showAboveKeyboard: true,
        );
    NavBarConfig buildReaderMode() {
      final document =
          _manager.state.results.elementAt(_manager.state.cardIndex);
      final managers = managersOf(document);

      void onBookmarkPressed() =>
          managers.discoveryCardManager.toggleBookmarkDocument(document);

      void onBookmarkLongPressed() => showAppBottomSheet(
            context,
            builder: (_) => MoveDocumentToCollectionBottomSheet(
              document: document,
              provider: managers.discoveryCardManager.state.processedDocument
                  ?.getProvider(document.resource),
              onError: showTooltip,
            ),
          );

      void onEditReaderModeSettingsPressed() => toggleOverlay(
            (_) => EditReaderModeSettingsMenu(
              onCloseMenu: removeOverlay,
            ),
          );

      return NavBarConfig(
        configIdSearch,
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

    return _manager.state.isFullScreen ? buildReaderMode() : buildDefault();
  }
}
