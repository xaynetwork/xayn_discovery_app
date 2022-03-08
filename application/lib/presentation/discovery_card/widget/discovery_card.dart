import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/gesture/drag_back_recognizer.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_card_headline_image.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/on_bookmark_changed_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_readability/xayn_readability.dart' show ProcessHtmlResult;

/// maximum context height.
const double _kMinImageFractionSize = .4;

/// signature for passing down a [DiscoveryCardController]
typedef ControllerCallback = void Function(DiscoveryCardController);

/// Implementation of [DiscoveryCardBase] which is used inside the feed view.
class DiscoveryCard extends DiscoveryCardBase {
  final DragCallback? onDrag;
  final VoidCallback? onDiscard;
  final ControllerCallback? onController;

  /// In pixels, how far must be dragged, before snapping back into feed view
  static const double dragThreshold = 200.0;

  const DiscoveryCard({
    Key? key,
    required bool isPrimary,
    required Document document,
    DiscoveryCardManager? discoveryCardManager,
    ImageManager? imageManager,
    this.onDiscard,
    this.onDrag,
    this.onController,
  }) : super(
          key: key,
          isPrimary: isPrimary,
          document: document,
          discoveryCardManager: discoveryCardManager,
          imageManager: imageManager,
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryCardState();
}

abstract class DiscoveryCardNavActions {
  void onBackNavPressed();
}

@immutable
class DiscoveryCardStandaloneArgs {
  const DiscoveryCardStandaloneArgs({
    required this.isPrimary,
    required this.document,
    required this.discoveryCardManager,
    required this.imageManager,
    this.onDiscard,
  });

  final bool isPrimary;
  final Document document;

  final DiscoveryCardManager discoveryCardManager;
  final ImageManager imageManager;
  final VoidCallback? onDiscard;
}

/// Implementation of [DiscoveryCardBase] which can be used as a navigation endpoint.
class DiscoveryCardStandalone extends DiscoveryCard {
  DiscoveryCardStandalone({
    Key? key,
    required DiscoveryCardStandaloneArgs args,
  }) : super(
          key: key,
          isPrimary: args.isPrimary,
          document: args.document,
          discoveryCardManager: args.discoveryCardManager,
          imageManager: args.imageManager,
          onDiscard: args.onDiscard,
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryCardPageState();
}

/// A controller which allows to programmatically close this widget
class DiscoveryCardController extends ChangeNotifier {
  /// the animation controller which controls the animation of [DiscoveryCard]
  final AnimationController _controller;

  DiscoveryCardController(this._controller);

  /// close the card, using an animation effect
  Future<void> animateToClose() async {
    // play out the animation...
    await _controller.animateTo(
      1.0,
      curve: Curves.easeIn,
    );

    // finally, reset the controller
    _controller.value = .0;
  }
}

class _DiscoveryCardState extends DiscoveryCardBaseState<DiscoveryCard>
    with OnBookmarkChangedMixin<DiscoveryCard>, TickerProviderStateMixin {
  late final AnimationController _openingAnimation;
  late final AnimationController _dragToCloseAnimation;
  late final DragBackRecognizer _recognizer;
  late final DragCallback _onDrag;
  late final DiscoveryCardController _controller;
  late final StreamSubscription<BuildContext> _updateNavBarListener;
  double _scrollOffset = .0;

  @override
  void initState() {
    super.initState();

    _onDrag = (distance) {
      final dX = distance.abs();

      _openingAnimation.value = (1.0 -
              (DiscoveryCard.dragThreshold - dX) / DiscoveryCard.dragThreshold)
          .clamp(_kMinImageFractionSize, 1.0);

      widget.onDrag?.call(dX);
    };

    _openingAnimation = AnimationController(
      vsync: this,
      duration: R.animations.cardOpenTransitionDuration,
    )..value = 1.0;

    _dragToCloseAnimation = AnimationController(
      vsync: this,
      duration: R.animations.cardCloseTransitionDuration,
    )..value = .0;

    _openingAnimation.addListener(() {
      setState(() {});
    });

    _dragToCloseAnimation.addListener(() =>
        _onDrag(_dragToCloseAnimation.value * DiscoveryCard.dragThreshold));

    _recognizer = DragBackRecognizer(
      debugOwner: this,
      threshold: DiscoveryCard.dragThreshold,
      onDrag: _onDrag,
      onDiscard: widget.onDiscard,
      animationControllerBuilder: () => AnimationController(
          vsync: this, duration: R.animations.cardSnapBackDuration),
    );

    _controller = DiscoveryCardController(_dragToCloseAnimation);

    _updateNavBarListener = discoveryCardManager.stream
        .map((state) => state.isBookmarked)
        .distinct()
        .map((_) => context)
        .listen(NavBarContainer.updateNavBar);

    widget.onController?.call(_controller);
  }

  @override
  void dispose() {
    _recognizer.dispose();

    _updateNavBarListener.cancel();
    _openingAnimation.stop(canceled: true);
    _openingAnimation.dispose();
    _dragToCloseAnimation.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final size = MediaQuery.of(context).size;
    // normalize the animation value to [0.0, 1.0]
    final normalizedValue = (_openingAnimation.value - _kMinImageFractionSize) /
        (1.0 - _kMinImageFractionSize);
    final processedDocument = state.processedDocument;
    final provider = processedDocument?.getProvider(webResource);

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final maskedImage = DiscoveryCardReaderModeHeadlineImage(child: image);
        final elements = DiscoveryCardElements(
          manager: discoveryCardManager,
          document: widget.document,
          explicitDocumentUserReaction: state.explicitDocumentUserReaction,
          title: webResource.title,
          timeToRead: state.processedDocument?.timeToRead ?? '',
          url: webResource.url,
          provider: provider,
          datePublished: webResource.datePublished,
          onLikePressed: () => discoveryCardManager.changeUserReaction(
            document: widget.document,
            userReaction: state.explicitDocumentUserReaction.isRelevant
                ? UserReaction.neutral
                : UserReaction.positive,
            context: FeedbackContext.explicit,
          ),
          onDislikePressed: () => discoveryCardManager.changeUserReaction(
            document: widget.document,
            userReaction: state.explicitDocumentUserReaction.isIrrelevant
                ? UserReaction.neutral
                : UserReaction.negative,
            context: FeedbackContext.explicit,
          ),
          onOpenUrl: () =>
              discoveryCardManager.openWebResourceUrl(widget.document),
          onBookmarkPressed: onBookmarkPressed,
          onBookmarkLongPressed: onBookmarkLongPressed(state),
          isBookmarked: state.isBookmarked,
          fractionSize: normalizedValue,
          useLargeTitle: false,
        );

        // Limits the max scroll-away distance,
        // to park the image only just outside the visible range at max, when it finally animates back,
        // then you see it 'falling' back immediately, instead of much, much later if scrolled far away.
        final outerScrollOffset = min(_scrollOffset * (1.0 - normalizedValue),
            _kMinImageFractionSize * constraints.maxHeight);

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            _buildReaderMode(
              processHtmlResult: state.processedDocument?.processHtmlResult,
              width: size.width,
              headlineHeight:
                  size.height * _kMinImageFractionSize + R.dimen.unit2,
            ),
            Positioned(
              top: -outerScrollOffset,
              left: 0,
              right: 0,
              child: Container(
                height: constraints.maxHeight * _openingAnimation.value,
                alignment: Alignment.topCenter,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    maskedImage,
                    elements,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    return Listener(
      onPointerDown: _recognizer.addPointer,
      behavior: HitTestBehavior.translucent,
      child: WillPopScope(
        onWillPop: _onWillPopScope,
        child: body,
      ),
    );
  }

  Future<bool> _onWillPopScope() async {
    await _controller.animateToClose();

    widget.onDiscard?.call();

    return false;
  }

  Widget _buildReaderMode({
    required ProcessHtmlResult? processHtmlResult,
    required double width,
    required double headlineHeight,
  }) {
    final readerMode = ReaderMode(
      title: title,
      textToSpeechLanguageCode: 'en',
      processHtmlResult: processHtmlResult,
      padding: EdgeInsets.only(
        left: R.dimen.unit3,
        right: R.dimen.unit3,
        // todo: bottom offset should compensate for the NavBar, so we need to calculate it
        bottom: R.dimen.unit15,
        top: headlineHeight,
      ),
      onProcessedHtml: () => _openingAnimation.animateTo(
        _kMinImageFractionSize,
        curve: Curves.fastOutSlowIn,
      ),
      onScroll: (position) => setState(() => _scrollOffset = position),
    );

    return ClipRRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxWidth: width,
        child: readerMode,
      ),
    );
  }

  @override
  void discoveryCardStateListener(DiscoveryCardState state) =>
      onBookmarkChanged(state);
}

class _DiscoveryCardPageState extends _DiscoveryCardState
    with NavBarConfigMixin {
  late final DiscoveryCardManager _discoveryCardManager;

  @override
  void initState() {
    _discoveryCardManager = di.get();

    super.initState();
  }

  @override
  Widget buildFromState(
          BuildContext context, DiscoveryCardState state, Widget image) =>
      Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: super.buildFromState(context, state, image),
        ),
      );

  @override
  NavBarConfig get navBarConfig {
    return NavBarConfig(
      [
        buildNavBarItemArrowLeft(
          onPressed: () => _discoveryCardManager.onBackNavPressed(),
        ),
        buildNavBarItemLike(
          isLiked: _discoveryCardManager
              .state.explicitDocumentUserReaction.isRelevant,
          onPressed: () => _discoveryCardManager.onFeedback(
            document: widget.document,
            userReaction: _discoveryCardManager
                    .state.explicitDocumentUserReaction.isRelevant
                ? UserReaction.neutral
                : UserReaction.positive,
          ),
        ),
        buildNavBarItemBookmark(
          isBookmarked: _discoveryCardManager.state.isBookmarked,
          onPressed: onBookmarkPressed,
          onLongPressed: onBookmarkLongPressed(_discoveryCardManager.state),
        ),
        buildNavBarItemShare(
          onPressed: () => _discoveryCardManager.shareUri(widget.document),
        ),
        buildNavBarItemDisLike(
          isDisLiked: _discoveryCardManager
              .state.explicitDocumentUserReaction.isIrrelevant,
          onPressed: () => _discoveryCardManager.onFeedback(
            document: widget.document,
            userReaction: _discoveryCardManager
                    .state.explicitDocumentUserReaction.isIrrelevant
                ? UserReaction.neutral
                : UserReaction.negative,
          ),
        ),
      ],
      isWidthExpanded: true,
    );
  }
}
