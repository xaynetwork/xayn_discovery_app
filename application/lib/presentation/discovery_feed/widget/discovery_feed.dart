import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_document_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

abstract class DiscoveryFeedNavActions {
  void onSearchNavPressed();

  void onPersonalAreaNavPressed();
}

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed>
    with
        WidgetsBindingObserver,
        NavBarConfigMixin,
        CardManagersMixin,
        TooltipStateMixin {
  DiscoveryFeedManager? _discoveryFeedManager;
  CardManagers? _managers;
  final CardViewController _cardViewController = CardViewController();
  final RatingDialogManager _ratingDialogManager = di.get();
  late final Future<DiscoveryFeedManager> _discoveryCardManagerFuture =
      di.getAsync();
  final Map<Document, Future<CardManagers>> _managerFutures =
      <Document, Future<CardManagers>>{};
  DiscoveryCardController? _currentCardController;

  int _totalResults = 0;
  double _dragDistance = .0;

  @override
  NavBarConfig get navBarConfig {
    final discoveryFeedManager = _discoveryFeedManager;

    if (discoveryFeedManager == null) {
      return NavBarConfig.hidden();
    }

    NavBarConfig buildDefault() => NavBarConfig(
          [
            buildNavBarItemHome(
                isActive: true,
                onPressed: () {
                  hideTooltip();
                  discoveryFeedManager.onHomeNavPressed();
                }),
            buildNavBarItemSearch(
              isDisabled: true,
              onPressed: discoveryFeedManager.onSearchNavPressed,
            ),
            buildNavBarItemPersonalArea(
              onPressed: () {
                hideTooltip();
                discoveryFeedManager.onPersonalAreaNavPressed();
              },
            ),
          ],
        );
    NavBarConfig buildReaderMode() {
      final document = discoveryFeedManager.state.results
          .elementAt(discoveryFeedManager.state.cardIndex);

      void onBookmarkPressed() async {
        final managers = await managersOf(document);
        final isBookmarked = await managers.discoveryCardManager
            .toggleBookmarkDocument(document);

        if (isBookmarked) {
          showTooltip(
            TooltipKeys.bookmarkedToDefault,
            parameters: [context, document],
          );
        }
      }

      void onBookmarkLongPressed() => showAppBottomSheet(
            context,
            builder: (_) => MoveDocumentToCollectionBottomSheet(
              document: document,
            ),
          );

      return NavBarConfig(
        [
          buildNavBarItemArrowLeft(onPressed: () async {
            await _currentCardController?.animateToClose();

            discoveryFeedManager.handleNavigateOutOfCard();
          }),
          buildNavBarItemLike(
              isLiked: document.isRelevant,
              onPressed: () async {
                final managers = await managersOf(document);

                managers.discoveryCardManager.changeDocumentFeedback(
                  document: document,
                  feedback: document.isRelevant
                      ? DocumentFeedback.neutral
                      : DocumentFeedback.positive,
                );
              }),
          buildNavBarItemBookmark(
            isBookmarked:
                _managers?.discoveryCardManager.state.isBookmarked ?? false,
            onPressed: onBookmarkPressed,
            onLongPressed: onBookmarkLongPressed,
          ),
          buildNavBarItemShare(onPressed: () async {
            final managers = await managersOf(document);

            managers.discoveryCardManager.shareUri(document);
          }),
          buildNavBarItemDisLike(
              isDisLiked: document.isIrrelevant,
              onPressed: () async {
                final managers = await managersOf(document);

                managers.discoveryCardManager.changeDocumentFeedback(
                  document: document,
                  feedback: document.isIrrelevant
                      ? DocumentFeedback.neutral
                      : DocumentFeedback.negative,
                );
              }),
        ],
        isWidthExpanded: true,
      );
    }

    return discoveryFeedManager.state.isFullScreen
        ? buildReaderMode()
        : buildDefault();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return _discoveryFeedManager?.handleActivityStatus(true);
      default:
        return _discoveryFeedManager?.handleActivityStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reduce the top padding when notch is present.
    var topPadding = MediaQuery.of(context).padding.top;
    if (topPadding - R.dimen.unit > 0) {
      topPadding = topPadding - R.dimen.unit;
    }

    final feedView = FutureBuilder<DiscoveryFeedManager>(
      future: _discoveryCardManagerFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _discoveryFeedManager = snapshot.requireData;

          NavBarContainer.updateNavBar(context);
        }

        return _buildFeedView();
      },
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: feedView,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardViewController.dispose();
    _discoveryFeedManager?.close();
    _managerFutures.clear();

    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  Widget _buildFeedView() {
    return LayoutBuilder(builder: (context, constraints) {
      final discoveryFeedManager = _discoveryFeedManager;

      if (discoveryFeedManager == null) {
        return Container();
      }

      // transform the cardNotchSize to a fractional value between [0.0, 1.0]
      final notchSize = 1.0 - R.dimen.cardNotchSize / constraints.maxHeight;

      return BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
        bloc: discoveryFeedManager,
        builder: (context, state) {
          final results = state.results;

          removeObsoleteCardManagers(state.removedResults);

          if (!state.isComplete && state.results.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.results.isEmpty) {
            return const Center();
          }

          if (state.isFullScreen) {
            // always update whenever state changes and when in full screen mode.
            // the only state update that can happen, is the change in like/dislike
            // of the presented document.
            // on that change, we need a redraw to update the like/dislike icons'
            // selection status.
            NavBarContainer.updateNavBar(context);
          }

          final document = results.elementAt(state.cardIndex);

          managersOf(document).then((it) {
            _managers = it;
            NavBarContainer.updateNavBar(context);
          });

          _totalResults = results.length;
          _cardViewController.index = min(_totalResults - 1, state.cardIndex);

          onIndexChanged(int index) {
            discoveryFeedManager.handleIndexChanged(index);
            _ratingDialogManager.handleIndexChanged(index);
          }

          return FeedView(
            key: Keys.feedView,
            cardViewController: _cardViewController,
            itemBuilder: _itemBuilder(
              results: results,
              isPrimary: true,
              isSwipingEnabled: !state.isFullScreen,
              isFullScreen: state.isFullScreen,
            ),
            secondaryItemBuilder: _itemBuilder(
              results: results,
              isPrimary: false,
              isSwipingEnabled: true,
              isFullScreen: false,
            ),
            boxBorderBuilder: _boxBorderBuilder(
              results: results,
              isFullScreen: state.isFullScreen,
            ),
            itemCount: _totalResults,
            onFinalIndex: discoveryFeedManager.handleLoadMore,
            onIndexChanged: _totalResults > 0 ? onIndexChanged : null,
            isFullScreen: state.isFullScreen,
            fullScreenOffsetFraction:
                _dragDistance / DiscoveryCard.dragThreshold,
            notchSize: notchSize,
            cardIdentifierBuilder: _createUniqueCardIdentity(results),
          );
        },
      );
    });
  }

  String Function(int) _createUniqueCardIdentity(Set<Document> results) =>
      (int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final document = results.elementAt(normalizedIndex);

        return document.documentId.toString();
      };

  Widget Function(BuildContext, int) _itemBuilder({
    required Set<Document> results,
    required bool isPrimary,
    required bool isSwipingEnabled,
    required bool isFullScreen,
  }) =>
      (BuildContext context, int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final document = results.elementAt(normalizedIndex);
        final discoveryFeedManager = _discoveryFeedManager!;
        final managersFuture =
            _managerFutures.putIfAbsent(document, () => managersOf(document));

        if (isPrimary) {
          discoveryFeedManager.handleViewType(
            document,
            isFullScreen ? DocumentViewMode.reader : DocumentViewMode.story,
          );
        }

        return FutureBuilder<CardManagers>(
            future: managersFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();

              final managers = snapshot.requireData;
              final card = isFullScreen
                  ? DiscoveryCard(
                      isPrimary: true,
                      document: document,
                      discoveryCardManager: managers.discoveryCardManager,
                      imageManager: managers.imageManager,
                      onDiscard: discoveryFeedManager.handleNavigateOutOfCard,
                      onDrag: _onFullScreenDrag,
                      onController: (controller) =>
                          _currentCardController = controller,
                    )
                  : GestureDetector(
                      onTap: () {
                        hideTooltip();
                        discoveryFeedManager.handleNavigateIntoCard();
                      },
                      child: DiscoveryFeedCard(
                        isPrimary: isPrimary,
                        document: document,
                        discoveryCardManager: managers.discoveryCardManager,
                        imageManager: managers.imageManager,
                      ),
                    );

              return SwipeableDiscoveryCard(
                manager: managers.discoveryCardManager,
                isPrimary: isPrimary,
                document: document,
                card: card,
                isSwipingEnabled: isSwipingEnabled,
              );
            });
      };

  BoxBorder? Function(int) _boxBorderBuilder({
    required Set<Document> results,
    required bool isFullScreen,
  }) =>
      (int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final document = results.elementAt(normalizedIndex);

        switch (document.feedback) {
          case DocumentFeedback.neutral:
            return null;
          case DocumentFeedback.positive:
            return Border.all(
              color: R.colors.swipeBackgroundRelevant,
              width: R.dimen.sentimentBorderSize,
            );
          case DocumentFeedback.negative:
            return Border.all(
              color: R.colors.swipeBackgroundIrrelevant,
              width: R.dimen.sentimentBorderSize,
            );
        }
      };

  void _onFullScreenDrag(double distance) {
    setState(() {
      _dragDistance = distance;
    });
  }
}
