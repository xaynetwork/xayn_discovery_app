import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
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
        TooltipStateMixin,
        OverlayStateMixin {
  late final DiscoveryFeedManager _discoveryFeedManager;
  final CardViewController _cardViewController = CardViewController();
  final RatingDialogManager _ratingDialogManager = di.get();
  DiscoveryCardController? _currentCardController;
  late final FeatureManager _featureManager = di.get<FeatureManager>();

  double _dragDistance = .0;

  @override
  NavBarConfig get navBarConfig {
    NavBarConfig buildDefault() => NavBarConfig(
          [
            buildNavBarItemHome(
                isActive: true,
                onPressed: () {
                  hideTooltip();
                  _discoveryFeedManager.onHomeNavPressed();
                }),
            buildNavBarItemSearch(
              isDisabled: true,
              onPressed: () => showTooltip(
                TooltipKeys.activeSearchDisabled,
                style: TooltipStyle.arrowDown,
              ),
            ),
            buildNavBarItemPersonalArea(
              onPressed: () {
                hideTooltip();
                _discoveryFeedManager.onPersonalAreaNavPressed();
              },
            ),
          ],
        );
    NavBarConfig buildReaderMode() {
      final document = _discoveryFeedManager.state.results
          .elementAt(_discoveryFeedManager.state.cardIndex);
      final managers = managersOf(document);

      void onBookmarkPressed() =>
          managers.discoveryCardManager.toggleBookmarkDocument(document);

      void onBookmarkLongPressed() => showAppBottomSheet(
            context,
            builder: (_) => MoveDocumentToCollectionBottomSheet(
              document: document,
              provider: managers.discoveryCardManager.state.processedDocument
                  ?.getProvider(document.webResource),
              onError: (tooltipKey) => showTooltip(tooltipKey),
            ),
          );

      return NavBarConfig(
        [
          buildNavBarItemArrowLeft(onPressed: () async {
            await _currentCardController?.animateToClose();
            removeOverlay();
            _discoveryFeedManager.handleNavigateOutOfCard();
          }),
          buildNavBarItemLike(
            isLiked: managers
                .discoveryCardManager.state.explicitDocumentFeedback.isRelevant,
            onPressed: () => managers.discoveryCardManager.onFeedback(
              document: document,
              feedback: managers.discoveryCardManager.state
                      .explicitDocumentFeedback.isRelevant
                  ? DocumentFeedback.neutral
                  : DocumentFeedback.positive,
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
          if (_featureManager.isReaderModeSettingsEnabled)
            buildNavBarItemEditFont(
              onPressed: () => toggleOverlay(
                (_) => Positioned(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      R.dimen.bottomBarDockedHeight +
                      R.dimen.unit4_25,
                  right: R.dimen.unit2,
                  width: R.dimen.unit22,
                  child: const EditReaderModeSettingsMenu(),
                ),
              ),
            ),
          buildNavBarItemDisLike(
            isDisLiked: managers.discoveryCardManager.state
                .explicitDocumentFeedback.isIrrelevant,
            onPressed: () => managers.discoveryCardManager.onFeedback(
              document: document,
              feedback: managers.discoveryCardManager.state
                      .explicitDocumentFeedback.isIrrelevant
                  ? DocumentFeedback.neutral
                  : DocumentFeedback.negative,
            ),
          ),
        ],
        isWidthExpanded: true,
      );
    }

    return _discoveryFeedManager.state.isFullScreen
        ? buildReaderMode()
        : buildDefault();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return _discoveryFeedManager.handleActivityStatus(true);
      default:
        return _discoveryFeedManager.handleActivityStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reduce the top padding when notch is present.
    var topPadding = MediaQuery.of(context).padding.top;
    if (topPadding - R.dimen.unit > 0) {
      topPadding = topPadding - R.dimen.unit;
    }

    final feedView = _buildFeedView();

    final body = Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: feedView,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        removeOverlay();
        return false;
      },
      child: body,
    );
  }

  @override
  void dispose() {
    _cardViewController.dispose();
    _discoveryFeedManager.close();

    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    _discoveryFeedManager = di.get();

    super.initState();
  }

  Widget _buildFeedView() {
    return LayoutBuilder(builder: (context, constraints) {
      final discoveryFeedManager = _discoveryFeedManager;

      // transform the cardNotchSize to a fractional value between [0.0, 1.0]
      final notchSize = 1.0 - R.dimen.cardNotchSize / constraints.maxHeight;

      return BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
        bloc: discoveryFeedManager,
        builder: (context, state) {
          final results = state.results;
          final totalResults = results.length;
          // ensure that we don't overflow the index.
          // this is because right now, we always refresh the feed when we
          // return to it, should solve itself once this is state-managed by
          // the real engine at some point.
          final cardIndex = min(totalResults - 1, state.cardIndex);

          removeObsoleteCardManagers(state.removedResults);

          if (!state.isComplete && state.results.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.results.isEmpty || cardIndex == -1) {
            return const Center();
          }

          NavBarContainer.updateNavBar(context);

          _cardViewController.index = cardIndex;

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
            itemCount: totalResults,
            onFinalIndex: discoveryFeedManager.handleLoadMore,
            onIndexChanged: totalResults > 0 ? onIndexChanged : null,
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
        final managers = managersOf(document);

        if (isPrimary) {
          _discoveryFeedManager.handleViewType(
            document,
            isFullScreen ? DocumentViewMode.reader : DocumentViewMode.story,
          );
        }

        final card = isFullScreen
            ? DiscoveryCard(
                isPrimary: true,
                document: document,
                discoveryCardManager: managers.discoveryCardManager,
                imageManager: managers.imageManager,
                onDiscard: _discoveryFeedManager.handleNavigateOutOfCard,
                onDrag: _onFullScreenDrag,
                onController: (controller) =>
                    _currentCardController = controller,
              )
            : GestureDetector(
                onTap: () {
                  hideTooltip();
                  _discoveryFeedManager.handleNavigateIntoCard();
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
          explicitDocumentFeedback:
              managers.discoveryCardManager.state.explicitDocumentFeedback,
          card: card,
          isSwipingEnabled: isSwipingEnabled,
        );
      };

  BoxBorder? Function(int) _boxBorderBuilder({
    required Set<Document> results,
    required bool isFullScreen,
  }) =>
      (int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final document = results.elementAt(normalizedIndex);
        final managers = managersOf(document);
        final state = managers.discoveryCardManager.state;

        switch (state.explicitDocumentFeedback) {
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

  void _onFullScreenDrag(double distance) =>
      setState(() => _dragDistance = distance.abs());
}
