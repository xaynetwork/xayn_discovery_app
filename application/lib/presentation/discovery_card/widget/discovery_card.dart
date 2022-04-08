import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide ImageErrorWidgetBuilder;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/gesture/drag_back_recognizer.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_shadow_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_shadow_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/app_scrollbar.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/traversal/traversal_shader.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';
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

  DiscoveryCard({
    Key? key,
    required bool isPrimary,
    required Document document,
    required FeedType feedType,
    DiscoveryCardManager? discoveryCardManager,
    ImageManager? imageManager,
    this.onDiscard,
    this.onDrag,
    this.onController,
    OnTtsData? onTtsData,
  }) : super(
          key: key,
          isPrimary: isPrimary,
          document: document,
          feedType: feedType,
          discoveryCardManager: discoveryCardManager,
          imageManager: imageManager,
          onTtsData: onTtsData,
          primaryCardShader: ({
            Key? key,
            required Uint8List bytes,
            required Uri uri,
            required ImageErrorWidgetBuilder noImageBuilder,
            Color? shadowColor,
            Curve? curve,
            double? width,
            double? height,
          }) =>
              TraversalShader(
            key: key,
            bytes: bytes,
            uri: uri,
            noImageBuilder: noImageBuilder,
            shadowColor: shadowColor,
            width: width,
            height: height,
            curve: curve,
            rendersOnlyOnce: true,
          ),
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
    required this.feedType,
    required this.discoveryCardManager,
    required this.imageManager,
    this.onDiscard,
  });

  final bool isPrimary;
  final Document document;
  final FeedType feedType;
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
          feedType: args.feedType,
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
    with OverlayMixin<DiscoveryCard>, TickerProviderStateMixin {
  late final AnimationController _openingAnimation;
  late final AnimationController _dragToCloseAnimation;
  late final DragBackRecognizer _recognizer;
  late final DragCallback _onDrag;
  late final DiscoveryCardController _controller;
  late final StreamSubscription<BuildContext> _updateNavBarListener;
  late final _scrollController = ScrollController(keepScrollOffset: false);
  late final DiscoveryCardShadowManager _shadowManager = di.get();
  double _scrollOffset = .0;

  @override
  OverlayManager get overlayManager => discoveryCardManager.overlayManager;

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
        .map((state) => state.bookmarkStatus == BookmarkStatus.bookmarked)
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

    _shadowManager.close();

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
        final elements = DiscoveryCardElements(
          manager: discoveryCardManager,
          document: widget.document,
          explicitDocumentUserReaction: state.explicitDocumentUserReaction,
          title: webResource.title,
          timeToRead: state.processedDocument?.timeToRead ?? '',
          url: webResource.url,
          provider: provider,
          datePublished: webResource.datePublished,
          isInteractionEnabled: widget.isPrimary,
          onLikePressed: () => onFeedbackPressed(UserReaction.positive),
          onDislikePressed: () => onFeedbackPressed(UserReaction.negative),
          onOpenUrl: () {
            widget.onTtsData?.call(TtsData.disabled());

            discoveryCardManager.openWebResourceUrl(
              widget.document,
              CurrentView.reader,
              widget.feedType,
            );
          },
          onToggleTts: () => widget.onTtsData?.call(
            TtsData(
              enabled: true,
              languageCode: widget.document.resource.language,
              uri: widget.document.resource.url,
              html: discoveryCardManager
                  .state.processedDocument?.processHtmlResult.contents,
            ),
          ),
          onBookmarkPressed: () => onBookmarkPressed(feedType: widget.feedType),
          onBookmarkLongPressed: onBookmarkLongPressed(state),
          bookmarkStatus: state.bookmarkStatus,
          fractionSize: normalizedValue,
          useLargeTitle: false,
          feedType: widget.feedType,
        );

        // Limits the max scroll-away distance,
        // to park the image only just outside the visible range at max, when it finally animates back,
        // then you see it 'falling' back immediately, instead of much, much later if scrolled far away.
        final outerScrollOffset = min(_scrollOffset * (1.0 - normalizedValue),
            _kMinImageFractionSize * constraints.maxHeight);

        return AppScrollbar(
          scrollController: _scrollController,
          child: Stack(
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
                      image,
                      elements,
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  @override
  Widget buildImage() =>
      BlocBuilder<DiscoveryCardShadowManager, DiscoveryCardShadowState>(
        bloc: _shadowManager,
        builder: (_, state) => super.buildImage(),
      );

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
      scrollController: _scrollController,
      title: title,
      languageCode: widget.document.resource.language,
      uri: widget.document.resource.url,
      processHtmlResult: processHtmlResult,
      padding: EdgeInsets.only(
        left: R.dimen.unit3,
        right: R.dimen.unit3,
        bottom: R.dimen.readerModeBottomPadding,
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
      configIdDiscoveryCard,
      [
        buildNavBarItemArrowLeft(
          onPressed: () => _discoveryCardManager.onBackNavPressed(),
        ),
        buildNavBarItemLike(
          isLiked: _discoveryCardManager
              .state.explicitDocumentUserReaction.isRelevant,
          onPressed: () => onFeedbackPressed(UserReaction.positive),
        ),
        buildNavBarItemBookmark(
          bookmarkStatus: _discoveryCardManager.state.bookmarkStatus,
          onPressed: () => onBookmarkPressed(feedType: widget.feedType),
          onLongPressed: onBookmarkLongPressed(_discoveryCardManager.state),
        ),
        buildNavBarItemShare(
          onPressed: () => _discoveryCardManager.shareUri(
            document: widget.document,
            feedType: widget.feedType,
          ),
        ),
        buildNavBarItemDisLike(
          isDisLiked: _discoveryCardManager
              .state.explicitDocumentUserReaction.isIrrelevant,
          onPressed: () => onFeedbackPressed(UserReaction.positive),
        ),
      ],
      isWidthExpanded: true,
    );
  }
}
