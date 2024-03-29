import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/widget/base_discovery_widget.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
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
          ) {
            final state = context.findAncestorStateOfType<_ActiveSearchState>();

            // lastUsedSearchTerm can only be null if a search was never done before,
            // in that case, show an empty card.
            // if lastUsedSearchTerm is not null, then we restore the past search / do a search without results,
            // and then "no-results" is relevant again.
            return state?.manager.lastUsedSearchTerm == null
                ? Container()
                : FeedNoResultsCard(
                    width: width,
                    height: height,
                  );
          },
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
  late final ActiveSearchManager _manager = di.get();
  late final CardManagersCache _cardManagersCache = di.get();

  @override
  ActiveSearchManager get manager => _manager;

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
              autofocus: _manager.state.cards.isEmpty,
              hint: _manager.lastUsedSearchTerm,
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
      final card = _manager.state.cards.elementAt(_manager.state.cardIndex);
      final document = card.requireDocument;
      final managers = _cardManagersCache.managersOf(document);

      void onBookmarkPressed() =>
          managers.discoveryCardManager.toggleBookmarkDocument(
            document,
            feedType: FeedType.search,
          );

      void onBookmarkLongPressed() =>
          managers.discoveryCardManager.onBookmarkLongPressed(
            document,
            feedType: FeedType.search,
          );

      void onEditReaderModeSettingsPressed() => toggleOverlay(
            builder: (_) => EditReaderModeSettingsMenu(
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
              feedType: FeedType.search,
            ),
          ),
          buildNavBarItemBookmark(
            bookmarkStatus: managers.discoveryCardManager.state.bookmarkStatus,
            onPressed: onBookmarkPressed,
            onLongPressed: onBookmarkLongPressed,
          ),
          buildNavBarItemShare(
              onPressed: () => managers.discoveryCardManager.shareDocument(
                    document: document,
                    feedType: FeedType.search,
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
              feedType: FeedType.search,
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
