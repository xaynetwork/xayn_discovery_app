import 'package:flutter/material.dart' hide ImageErrorWidgetBuilder;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart' hide WidgetBuilder;
import 'package:xayn_discovery_app/domain/item_renderer/card.dart'
    as item_renderer;
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/custom_card_manager.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/custom_card_manager_state.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/discovery_state.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/custom_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_report/widget/discovery_engine_report_overlay.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_app/presentation/premium/utils/subsciption_trial_banner_state_mixin.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/tts/widget/tts.dart';
import 'package:xayn_discovery_app/presentation/utils/reader_mode_settings_extension.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/shimmering_feed_view.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// A widget which displays a list of discovery results.
abstract class BaseDiscoveryWidget<T extends BaseDiscoveryManager>
    extends StatefulWidget {
  final AuxiliaryCardBuilder? noItemsBuilder;
  final AuxiliaryCardBuilder? finalItemBuilder;
  final AuxiliaryCardBuilder? loadingItemBuilder;

  const BaseDiscoveryWidget({
    Key? key,
    this.noItemsBuilder,
    this.finalItemBuilder,
    this.loadingItemBuilder,
  }) : super(key: key);
}

abstract class BaseDiscoveryFeedState<T extends BaseDiscoveryManager,
        W extends BaseDiscoveryWidget> extends State<W>
    with
        WidgetsBindingObserver,
        NavBarConfigMixin,
        TooltipStateMixin<W>,
        SubscriptionTrialBannerStateMixin<W>,
        OverlayMixin<W>,
        OverlayStateMixin<W> {
  late final CardViewController _cardViewController = CardViewController();
  late final RatingDialogManager _ratingDialogManager = di.get();
  late final FeatureManager featureManager = di.get();
  late final CardManagersCache cardManagersCache = di.get();

  @override
  OverlayManager get overlayManager => manager.overlayManager;

  /// no need to dispose here, handled by the Card Widget itself
  DiscoveryCardController? currentCardController;

  double _dragDistance = .0;

  bool _trialBannerShown = false;

  T get manager;
  CustomCardManager get customCardManager;

  CardViewController get cardViewController => _cardViewController;

  TtsData ttsData = TtsData.disabled();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return manager.handleActivityStatus(true);
      default:
        return manager.handleActivityStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<BaseDiscoveryManager, DiscoveryState>(
        bloc: manager,
        listener: (context, state) {
          ///TODO: Uncomment once TY-2592 is fixed
          // if (state.isInErrorState) showErrorBottomSheet();

          customCardManager.updateListing(state.results);
          _showTrialBannerIfNeeded(state.subscriptionStatus);
        },
        builder: (context, state) {
          // this is for:
          // - any menu bar
          // - the iOS notch
          // - etc...
          final topPadding = MediaQuery.of(context).viewPadding.top;

          final feed = BlocBuilder<CustomCardManager, CustomCardManagerState>(
            bloc: customCardManager,
            builder: (context, customCardsState) =>
                _buildFeedView(state, customCardsState),
          );

          final readerModeBgColor = state.readerModeBackgroundColor;
          final bgColor = readerModeBgColor == null
              ? R.colors.homePageBackground
              : R.isDarkMode
                  ? readerModeBgColor.dark.color
                  : readerModeBgColor.light.color;

          return AppScaffold(
            /// resizing the scaffold is set to false since the keyboard could be
            /// triggered when creating a collection from the bottom sheet and the
            /// feed should look the same in that process
            ///
            resizeToAvoidBottomInset: false,
            backgroundColor: bgColor,
            body: Tts(
              data: ttsData,
              child: Padding(
                padding: EdgeInsets.only(top: topPadding),
                child: featureManager.showDiscoveryEngineReportOverlay
                    ? DiscoveryEngineReportOverlay(child: feed)
                    : feed,
              ),
            ),
          );
        },
      );

  @override
  void dispose() {
    _cardViewController.dispose();
    featureManager.close();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  Widget _buildFeedView(
    DiscoveryState state,
    CustomCardManagerState customCardManagerState,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      // transform the cardNotchSize to a fractional value between [0.0, 1.0]
      final notchSize = 1.0 - R.dimen.cardNotchSize / constraints.maxHeight;
      final results = customCardManagerState.cards;
      final totalResults = results.length;
      final isMissingNoItemsBuilders =
          totalResults == 0 && widget.noItemsBuilder == null;

      if (state.shouldUpdateNavBar) NavBarContainer.updateNavBar(context);

      if (!state.isComplete || isMissingNoItemsBuilders) {
        return _buildLoadingIndicator(notchSize);
      }

      if (state.cardIndex < totalResults &&
          _cardViewController.index != state.cardIndex) {
        // since custom cards are added in a post-phase,
        // we may need to count all custom cards, prior to the engine index,
        // and just add that total to the engine count.
        // e.g. manager returns 4 Documents,
        // then, customCardManager inject a custom card in the middle,
        // so then if the engine index is 3, it will become 4 instead,
        // making up for the uncounted custom card at position 2.
        final customCardsBeforeIndex = results
            .take(state.cardIndex)
            .where((it) => it.type != item_renderer.CardType.document)
            .length;
        final normalizedCardIndex = state.cardIndex + customCardsBeforeIndex;

        _cardViewController.index = normalizedCardIndex;
      }

      onIndexChanged(int index) {
        manager.handleIndexChanged(index, results.elementAt(index));
        _ratingDialogManager.handleIndexChanged(index);
        ttsData = TtsData.disabled();
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
        onFinalIndex: manager.handleLoadMore,
        onIndexChanged: totalResults > 0 ? onIndexChanged : null,
        isFullScreen: state.isFullScreen,
        fullScreenOffsetFraction: _dragDistance / DiscoveryCard.dragThreshold,
        notchSize: notchSize,
        cardIdentifierBuilder: _createUniqueCardIdentity(results),
        noItemsBuilder: widget.noItemsBuilder,
        finalItemBuilder: state.didReachEnd
            ? widget.finalItemBuilder
            : widget.loadingItemBuilder,
      );
    });
  }

  Widget _buildLoadingIndicator(double notchSize) =>
      ShimmeringFeedView(notchSize: notchSize);

  String Function(int) _createUniqueCardIdentity(
          Set<item_renderer.Card> results) =>
      (int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final card = results.elementAt(normalizedIndex);

        return card.document?.documentId.toString() ??
            'custom_card_${card.hashCode}';
      };

  Widget Function(BuildContext, int) _itemBuilder({
    required Set<item_renderer.Card> results,
    required bool isPrimary,
    required bool isSwipingEnabled,
    required bool isFullScreen,
  }) =>
      (BuildContext context, int index) {
        final normalizedIndex = index.clamp(0, results.length - 1);
        final card = results.elementAt(normalizedIndex);
        final document = card.document;
        final managers = card.type == item_renderer.CardType.document
            ? cardManagersCache.managersOf(card.requireDocument)
            : null;

        onTapPrimary() async {
          hideTooltip();

          if (document != null) manager.maybeNavigateIntoCard(document);
        }

        onTapSecondary() => _cardViewController.jump(JumpDirection.down);

        if (isPrimary && document != null) {
          manager.handleViewType(
            document,
            isFullScreen ? DocumentViewMode.reader : DocumentViewMode.story,
          );
        }

        final shaderType =
            document != null ? _getShaderType(document.resource) : null;
        final cardWidget = isFullScreen
            ? DiscoveryCard(
                isPrimary: true,
                document: document!,
                onDiscard: () {
                  manager.triggerHapticFeedbackMedium();
                  return manager.handleNavigateOutOfCard(document);
                },
                onDrag: _onFullScreenDrag,
                onController: (controller) =>
                    currentCardController = controller,
                onTtsData: (it) => setState(
                    () => ttsData = ttsData.enabled ? TtsData.disabled() : it),
                feedType: manager.feedType,
                primaryCardShader: ShaderFactory.fromType(
                  shaderType!,
                  transitionToIdle: true,
                ),
              )
            : GestureDetector(
                onTap: isPrimary ? onTapPrimary : onTapSecondary,
                child: document != null
                    ? DiscoveryFeedCard(
                        isPrimary: isPrimary,
                        document: document,
                        primaryCardShader: ShaderFactory.fromType(shaderType!),
                        onTtsData: (it) => setState(() => ttsData =
                            ttsData.enabled ? TtsData.disabled() : it),
                        feedType: manager.feedType,
                      )
                    : CustomCard(
                        cardType: card.type,
                        primaryCardShader:
                            ShaderFactory.fromType(ShaderType.static),
                      ),
              );

        return Semantics(
            button: true,
            child: document != null
                ? SwipeableDiscoveryCard(
                    onSwipe: (option) =>
                        managers!.discoveryCardManager.onFeedback(
                      document: document,
                      userReaction: option.toUserReaction(),
                      feedType: manager.feedType,
                    ),
                    isPrimary: isPrimary,
                    document: document,
                    explicitDocumentUserReaction: managers!.discoveryCardManager
                        .state.explicitDocumentUserReaction,
                    card: cardWidget,
                    isSwipingEnabled: isSwipingEnabled,
                    onFling: managers
                        .discoveryCardManager.triggerHapticFeedbackMedium,
                  )
                : cardWidget);
      };

  ShaderType _getShaderType(NewsResource newsResource) {
    // A document doesn't have a unique 'index',
    // and also, the index within the feed is not static, as older
    // documents are removed.
    // So while not ideal, using hashcode to consistently resolve the exact
    // same shader does work:
    switch (newsResource.hashCode % 3) {
      case 0:
        return ShaderType.static;
      case 1:
        return ShaderType.pan;
      default:
        return ShaderType.zoom;
    }
  }

  BoxBorder? Function(int) _boxBorderBuilder({
    required Set<item_renderer.Card> results,
    required bool isFullScreen,
  }) =>
      (int index) {
        if (isFullScreen) return null;

        final normalizedIndex = index.clamp(0, results.length - 1);
        final card = results.elementAt(normalizedIndex);
        final document = card.document;
        final managers =
            document != null ? cardManagersCache.managersOf(document) : null;
        final state = managers?.discoveryCardManager.state;

        if (state == null) {
          return null;
        }

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

  void _showTrialBannerIfNeeded(SubscriptionStatus? subscriptionStatus) {
    if (_trialBannerShown) return;

    final needToShowBanner = subscriptionStatus?.isLastDayOfFreeTrial == true &&
        manager.feedType == FeedType.feed;

    if (needToShowBanner) {
      _trialBannerShown = true;
      showTrialBanner(
        trialEndDate: subscriptionStatus!.trialEndDate!,
        onTap: manager.onPaymentTrialBannerTap,
      );
    }
  }
}

extension on SwipeOption {
  UserReaction toUserReaction() {
    switch (this) {
      case SwipeOption.like:
        return UserReaction.positive;
      case SwipeOption.neutral:
        return UserReaction.neutral;
      case SwipeOption.dislike:
        return UserReaction.negative;
    }
  }
}
