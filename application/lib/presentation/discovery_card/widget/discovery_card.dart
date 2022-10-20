import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/gesture/drag_back_recognizer.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/app_scrollbar.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/card_menu_indicator.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_header_menu.dart';
import 'package:xayn_discovery_app/presentation/images/widget/arc.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
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
    this.onDiscard,
    this.onDrag,
    this.onController,
    OnTtsData? onTtsData,
    ShaderBuilder? primaryCardShader,
  }) : super(
          key: key,
          isPrimary: isPrimary,
          document: document,
          feedType: feedType,
          onTtsData: onTtsData,
          primaryCardShader:
              primaryCardShader ?? ShaderFactory.fromType(ShaderType.static),
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryCardState();
}

abstract class DiscoveryCardNavActions {
  void onBackNavPressed();

  void onManageSourcesPressed();
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
    with TickerProviderStateMixin, OverlayStateMixin {
  late final AnimationController _openingAnimation;
  late final AnimationController _dragToCloseAnimation;
  late final DragBackRecognizer _recognizer;
  late final DragCallback _onDrag;
  late final DiscoveryCardController _controller;
  late final StreamSubscription<BuildContext> _updateNavBarListener;
  late final _scrollController = ScrollController(keepScrollOffset: false);
  double _scrollOffset = .0;

  @override
  OverlayManager get overlayManager => discoveryCardManager.overlayManager;

  double get fractionSize =>
      (_openingAnimation.value - _kMinImageFractionSize) /
      (1.0 - _kMinImageFractionSize);

  double get invertedFractionSize => 1.0 - fractionSize;

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

    super.dispose();
  }

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final size = MediaQuery.of(context).size;
    // normalize the animation value to [0.0, 1.0]
    final normalizedValue = fractionSize;
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
          onProviderSectionTap: () {
            widget.onTtsData?.call(TtsData.disabled());

            discoveryCardManager.openWebResourceUrl(
              widget.document,
              CurrentView.story,
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
          onBookmarkLongPressed: onBookmarkLongPressed(),
          bookmarkStatus: state.bookmarkStatus,
          fractionSize: normalizedValue,
          useLargeTitle: false,
          feedType: widget.feedType,
        );

        final normalizedScrollOffset = _scrollOffset * (1.0 - normalizedValue);
        // Limits the max scroll-away distance,
        // to park the image only just outside the visible range at max, when it finally animates back,
        // then you see it 'falling' back immediately, instead of much, much later if scrolled far away.
        final outerScrollOffset = min(normalizedScrollOffset,
            _kMinImageFractionSize * constraints.maxHeight);
        // todo: magic number!
        // there is a render issue with Flutter, so while we await a fix here:
        // the card image is a combination of an image and a linear gradient.
        // the Flutter bug is as following:
        // when "rasterizing", sometimes the size of a widget is a double value,
        // when this happens, Flutter will try to resolve to the nearest logical pixel value, which depends on the DPI as well.
        // now for images, it seems to do ceil(), yet for things like gradient, it tends to floor()
        // as a temp fix, we added an extra pixel to the size of the gradient.
        // here, we add the extra pixel again, so that the image + gradient is fully scrolled-out when needed
        // @See base_painter.dart, in the paint method, where the extra pixel is added
        const renderArtefactSize = 2.0;

        final readerModePadding = EdgeInsets.only(
          left: R.dimen.unit3,
          right: R.dimen.unit3,
          bottom: R.dimen.readerModeBottomPadding,
          top: size.height / 2 + R.dimen.unit8,
        );

        // calculated area values for the elements
        final elmsMinPos = constraints.maxHeight / 2.7;
        final elmsMaxPos = 2 * constraints.maxHeight / 3;
        final elmsDelta = elmsMaxPos - elmsMinPos;
        final elmsBottom = invertedFractionSize * 2 * constraints.maxHeight / 9;
        final elmsPos = elmsMinPos + elmsDelta * fractionSize;

        final indicator = Positioned(
          top: R.dimen.unit2,
          right: R.dimen.unit2,
          child: CardMenuIndicator(
            isInteractionEnabled: widget.isPrimary,
            onOpenHeaderMenu: () {
              widget.onTtsData?.call(TtsData.disabled());

              toggleOverlay(
                builder: (_) => DiscoveryCardHeaderMenu(
                  itemsMap: _buildDiscoveryCardHeaderMenuItems,
                  source: Source.fromJson(widget.document.resource.url.host),
                  onClose: removeOverlay,
                ),
                useRootOverlay: true,
              );
            },
          ),
        );

        final title = Positioned(
          top: elmsPos - normalizedScrollOffset,
          bottom: invertedFractionSize * elmsBottom + normalizedScrollOffset,
          left: 0,
          right: 0,
          child: elements,
        );

        final imageWithArc = Positioned(
          top: -outerScrollOffset - renderArtefactSize,
          left: 0,
          right: 0,
          child: Container(
            height: constraints.maxHeight * _openingAnimation.value,
            alignment: Alignment.topCenter,
            child: image,
          ),
        );

        final readerMode = _buildReaderMode(
          processHtmlResult: state.processedDocument?.processHtmlResult,
          width: size.width,
          padding: readerModePadding,
        );

        return AppScrollbar(
          scrollController: _scrollController,
          child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      readerMode,
                      imageWithArc,
                      title,
                      indicator,
                    ],
                  )),
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
  Widget buildImage() => Arc(
        fractionSize: invertedFractionSize,
        arcVariation: discoveryCardManager.state.arcVariation,
        child: super.buildImage(),
      );

  Future<bool> _onWillPopScope() async {
    await _controller.animateToClose();

    widget.onDiscard?.call();

    return false;
  }

  Widget _buildReaderMode({
    required ProcessHtmlResult? processHtmlResult,
    required double width,
    required EdgeInsets padding,
  }) {
    final readerMode = ReaderMode(
      scrollController: _scrollController,
      title: title,
      languageCode: widget.document.resource.language,
      uri: widget.document.resource.url,
      processHtmlResult: processHtmlResult,
      padding: padding,
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

  Map<DiscoveryCardHeaderMenuItemEnum, DiscoveryCardHeaderMenuItem>
      get _buildDiscoveryCardHeaderMenuItems => {
            DiscoveryCardHeaderMenuItemEnum.openInBrowser:
                DiscoveryCardHeaderMenuHelper.buildOpenInBrowserItem(
              onTap: () {
                removeOverlay();
                discoveryCardManager.openWebResourceUrl(
                  widget.document,
                  CurrentView.story,
                  widget.feedType,
                );
              },
            ),
            DiscoveryCardHeaderMenuItemEnum.excludeSource:
                DiscoveryCardHeaderMenuHelper.buildExcludeSourceItem(
              onTap: () {
                removeOverlay();
                discoveryCardManager.onExcludeSource(
                  document: widget.document,
                );
              },
            ),
            DiscoveryCardHeaderMenuItemEnum.includeSource:
                DiscoveryCardHeaderMenuHelper.buildIncludeSourceBackItem(
              onTap: () {
                removeOverlay();
                discoveryCardManager.onIncludeSource(
                  document: widget.document,
                );
              },
            ),
          };
}
