import 'dart:async';
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
import 'package:xayn_discovery_app/presentation/discovery_engine_report/widget/discovery_engine_report_overlay.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/widget/edit_reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/premium/utils/subsciption_trial_banner_state_mixin.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';
import 'package:xayn_discovery_app/presentation/widget/widget_testable_progress_indicator.dart';
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
        SubscriptionTrialBannerStateMixin,
        OverlayStateMixin,
        ErrorHandlingMixin {
  late final DiscoveryFeedManager _discoveryFeedManager;
  late final StreamSubscription<BuildContext> _navBarUpdateListener;
  final CardViewController _cardViewController = CardViewController();
  final RatingDialogManager _ratingDialogManager = di.get();
  final FeatureManager _featureManager = di.get();
  DiscoveryCardController? _currentCardController;

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
            await _currentCardController?.animateToClose();
            _discoveryFeedManager.handleNavigateOutOfCard();
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
          if (_featureManager.isReaderModeSettingsEnabled)
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
  Widget build(BuildContext context) =>
      BlocConsumer<DiscoveryFeedManager, DiscoveryFeedState>(
        bloc: _discoveryFeedManager,
        listener: (context, state) {
          if (state.isInErrorState) showErrorBottomSheet(context);
        },
        builder: (context, state) {
          // this is for:
          // - any menu bar
          // - the iOS notch
          // - etc...
          final topPadding = MediaQuery.of(context).viewPadding.top;

          final feed = _buildFeedView(state);

          return Scaffold(
            /// resizing the scaffold is set to false since the keyboard could be
            /// triggered when creating a collection from the bottom sheet and the
            /// feed should look the same in that process
            ///
            resizeToAvoidBottomInset: false,
            backgroundColor: R.colors.homePageBackground,
            body: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: _featureManager.showDiscoveryEngineReportOverlay
                  ? DiscoveryEngineReportOverlay(child: feed)
                  : feed,
            ),
          );
        },
      );

  @override
  void dispose() {
    _cardViewController.dispose();
    _discoveryFeedManager.close();
    _navBarUpdateListener.cancel();

    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    _discoveryFeedManager = di.get()..handleCheckMarkets();

    _navBarUpdateListener = _discoveryFeedManager.stream
        .where((state) => state.shouldUpdateNavBar)
        .map((_) => context)
        .listen(NavBarContainer.updateNavBar);

    super.initState();
  }

  Widget _buildFeedView(DiscoveryFeedState state) {
    return LayoutBuilder(builder: (_, constraints) {
      // transform the cardNotchSize to a fractional value between [0.0, 1.0]
      final notchSize = 1.0 - R.dimen.cardNotchSize / constraints.maxHeight;

      final results = state.results;
      final totalResults = results.length;
      // ensure that we don't overflow the index.
      // this is because right now, we always refresh the feed when we
      // return to it, should solve itself once this is state-managed by
      // the real engine at some point.
      final cardIndex = min(totalResults - 1, state.cardIndex);

      removeObsoleteCardManagers(state.removedResults);

      if (state.results.isEmpty || cardIndex == -1) {
        return _buildLoadingIndicator();
      }

      _cardViewController.index = cardIndex;

      onIndexChanged(int index) {
        _discoveryFeedManager.handleIndexChanged(index);
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
        onFinalIndex: _discoveryFeedManager.handleLoadMore,
        onIndexChanged: totalResults > 0 ? onIndexChanged : null,
        isFullScreen: state.isFullScreen,
        fullScreenOffsetFraction: _dragDistance / DiscoveryCard.dragThreshold,
        notchSize: notchSize,
        cardIdentifierBuilder: _createUniqueCardIdentity(results),
      );
    });
  }

  Widget _buildLoadingIndicator() => const Center(
        ///TODO replace with shimmer
        child: WidgetTestableProgressIndicator(),
      );

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

        onTapPrimary() {
          hideTooltip();

          _discoveryFeedManager.handleNavigateIntoCard();
        }

        onTapSecondary() => _cardViewController.jump(JumpDirection.down);

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
                onTap: isPrimary ? onTapPrimary : onTapSecondary,
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
          explicitDocumentUserReaction:
              managers.discoveryCardManager.state.explicitDocumentUserReaction,
          card: card,
          isSwipingEnabled: isSwipingEnabled,
        );
      };

  BoxBorder? Function(int) _boxBorderBuilder({
    required Set<Document> results,
    required bool isFullScreen,
  }) =>
      (int index) {
        if (isFullScreen) return null;

        final normalizedIndex = index.clamp(0, results.length - 1);
        final document = results.elementAt(normalizedIndex);
        final managers = managersOf(document);
        final state = managers.discoveryCardManager.state;

        switch (state.explicitDocumentUserReaction) {
          case UserReaction.neutral:
            return null;
          case UserReaction.positive:
            return Border.all(
              color: R.colors.swipeBackgroundRelevant,
              width: R.dimen.sentimentBorderSize,
            );
          case UserReaction.negative:
            return Border.all(
              color: R.colors.swipeBackgroundIrrelevant,
              width: R.dimen.sentimentBorderSize,
            );
        }
      };

  void _onFullScreenDrag(double distance) =>
      setState(() => _dragDistance = distance.abs());
}
