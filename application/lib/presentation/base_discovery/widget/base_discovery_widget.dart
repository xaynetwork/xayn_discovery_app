import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_report/widget/discovery_engine_report_overlay.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/premium/utils/subsciption_trial_banner_state_mixin.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/widget_testable_progress_indicator.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// A widget which displays a list of discovery results.
abstract class BaseDiscoveryWidget<T extends BaseDiscoveryManager>
    extends StatefulWidget {
  final T manager;

  const BaseDiscoveryWidget({
    Key? key,
    required this.manager,
  }) : super(key: key);
}

abstract class BaseDiscoveryFeedState<T extends BaseDiscoveryManager,
        W extends BaseDiscoveryWidget> extends State<W>
    with
        WidgetsBindingObserver,
        NavBarConfigMixin,
        CardManagersMixin,
        TooltipStateMixin,
        SubscriptionTrialBannerStateMixin,
        OverlayStateMixin {
  final CardViewController _cardViewController = CardViewController();
  final RatingDialogManager _ratingDialogManager = di.get();
  final FeatureManager featureManager = di.get();
  DiscoveryCardController? currentCardController;

  double _dragDistance = .0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return widget.manager.handleActivityStatus(true);
      default:
        return widget.manager.handleActivityStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BaseDiscoveryManager, DiscoveryState>(
        bloc: widget.manager,
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
              child: featureManager.showDiscoveryEngineReportOverlay
                  ? DiscoveryEngineReportOverlay(child: feed)
                  : feed,
            ),
          );
        },
      );

  @override
  void dispose() {
    _cardViewController.dispose();

    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    widget.manager.handleCheckMarkets();

    super.initState();
  }

  Widget _buildFeedView(DiscoveryState state) {
    return LayoutBuilder(builder: (context, constraints) {
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

      if (state.shouldUpdateNavBar) NavBarContainer.updateNavBar(context);

      if (state.results.isEmpty || cardIndex == -1) {
        return _buildLoadingIndicator();
      }

      _cardViewController.index = cardIndex;

      onIndexChanged(int index) {
        widget.manager.handleIndexChanged(index);
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
        onFinalIndex: widget.manager.handleLoadMore,
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

          widget.manager.handleNavigateIntoCard();
        }

        onTapSecondary() => _cardViewController.jump(JumpDirection.down);

        if (isPrimary) {
          widget.manager.handleViewType(
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
                onDiscard: widget.manager.handleNavigateOutOfCard,
                onDrag: _onFullScreenDrag,
                onController: (controller) =>
                    currentCardController = controller,
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
