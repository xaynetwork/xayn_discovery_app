import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/gesture/drag_back_recognizer.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_readability/xayn_readability.dart' show ProcessHtmlResult;

/// the minimum fraction height of the card image.
/// This value must be in the range of [0.0, 1.0], where 1.0 is the
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

/// Implementation of [DiscoveryCardBase] which can be used as a navigation endpoint.
class DiscoveryCardScreen extends DiscoveryCard {
  const DiscoveryCardScreen({
    Key? key,
    required bool isPrimary,
    required Document document,
  }) : super(
          key: key,
          isPrimary: isPrimary,
          document: document,
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
    with TickerProviderStateMixin {
  late final AnimationController _openingAnimation;
  late final AnimationController _dragToCloseAnimation;
  late final DragBackRecognizer _recognizer;
  late final DragCallback _onDrag;
  late final DiscoveryCardController _controller;
  double _scrollOffset = .0;

  @override
  void initState() {
    super.initState();

    _onDrag = (distance) {
      _openingAnimation.value = (1.0 -
              (DiscoveryCard.dragThreshold - distance) /
                  DiscoveryCard.dragThreshold)
          .clamp(_kMinImageFractionSize, 1.0);

      widget.onDrag?.call(distance);
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

    widget.onController?.call(_controller);
  }

  @override
  void dispose() {
    _recognizer.dispose();

    _openingAnimation.stop(canceled: true);
    _openingAnimation.dispose();
    _dragToCloseAnimation.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final mediaQuery = MediaQuery.of(context);
    // normalize the animation value to [0.0, 1.0]
    final normalizedValue = (_openingAnimation.value - _kMinImageFractionSize) /
        (1.0 - _kMinImageFractionSize);

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final maskedImage = Container(
          foregroundDecoration: BoxDecoration(
            gradient: buildGradient(opacity: _openingAnimation.value),
          ),
          child: image,
        );
        final elements = DiscoveryCardElements(
          manager: discoveryCardManager,
          title: webResource.title,
          timeToRead: state.output?.timeToRead ?? '',
          url: webResource.url,
          provider: webResource.provider,
          datePublished: webResource.datePublished,
          onLikePressed: () => discoveryCardManager.changeDocumentFeedback(
            documentId: widget.document.documentId,
            feedback: DocumentFeedback.positive,
          ),
          onDislikePressed: () => discoveryCardManager.changeDocumentFeedback(
            documentId: widget.document.documentId,
            feedback: DocumentFeedback.negative,
          ),
          fractionSize: normalizedValue,
        );

        return Stack(
          children: [
            Positioned.fill(
                child: _buildReaderMode(
              mediaQuery.size,
              state.output?.processHtmlResult,
            )),
            Positioned(
              top: -_scrollOffset * (1.0 - normalizedValue),
              left: 0,
              right: 0,
              child: Container(
                height: constraints.maxHeight * _openingAnimation.value,
                alignment: Alignment.topCenter,
                child: Stack(
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

  Widget _buildReaderMode(Size size, ProcessHtmlResult? processHtmlResult) {
    final readerMode = ReaderMode(
      title: title,
      snippet: snippet,
      imageUri: Uri.parse(imageUrl),
      processHtmlResult: processHtmlResult,
      padding: EdgeInsets.only(
        left: R.dimen.unit2,
        right: R.dimen.unit2,
        // todo: bottom offset should compensate for the NavBar, so we need to calculate it
        bottom: R.dimen.unit12,
        top: size.height * _kMinImageFractionSize,
      ),
      onProcessedHtml: () => _openingAnimation.animateTo(
        _kMinImageFractionSize,
        curve: Curves.fastOutSlowIn,
      ),
      onScroll: (position) => setState(() => _scrollOffset = position),
    );

    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
      bloc: discoveryCardManager,
      builder: (context, state) => ClipRRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxWidth: size.width,
          child: readerMode,
        ),
      ),
    );
  }
}

class _DiscoveryCardPageState extends _DiscoveryCardState {
  @override
  Widget buildFromState(
          BuildContext context, DiscoveryCardState state, Widget image) =>
      Scaffold(
        body: SafeArea(
          bottom: false,
          child: super.buildFromState(context, state, image),
        ),
      );
}
