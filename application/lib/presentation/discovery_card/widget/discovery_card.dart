import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_footer.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';

const Duration _kSnapBackDuration = Duration(milliseconds: 450);
const Duration _kOpenCardDuration = Duration(milliseconds: 1000);
const Curve _kSnapBackCurve = Curves.elasticOut;
const double _kMinImageFractionSize = .4;
const double _kFlingVelocity = 2000.0;

typedef DragCallback = void Function(double);
typedef AnimationControllerBuilder = AnimationController Function();
typedef ControllerCallback = void Function(DiscoveryCardController);

/// Implementation of [DiscoveryCardBase] which is used inside the feed view.
class DiscoveryCard extends DiscoveryCardBase {
  final DragCallback? onDrag;
  final VoidCallback? onDiscard;
  final ControllerCallback? onController;

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
          imageBoxFit: BoxFit.fitWidth,
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

class _DiscoveryCardState extends DiscoveryCardBaseState<DiscoveryCard>
    with TickerProviderStateMixin {
  late final AnimationController _openingAnimation;
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
      duration: _kOpenCardDuration,
    )..value = 1.0;

    _openingAnimation.addListener(() {
      setState(() {});
    });

    _recognizer = DragBackRecognizer(
      debugOwner: this,
      onDrag: _onDrag,
      onDiscard: widget.onDiscard,
      animationControllerBuilder: () =>
          AnimationController(vsync: this, duration: _kSnapBackDuration),
    );

    _controller = DiscoveryCardController(_openingAnimation);

    widget.onController?.call(_controller);
  }

  @override
  void dispose() {
    _recognizer.dispose();

    _openingAnimation.stop(canceled: true);
    _openingAnimation.dispose();

    super.dispose();
  }

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final mediaQuery = MediaQuery.of(context);
    // normalize the animation value to [0.0, 1.0]
    final normalizedValue = (_openingAnimation.value - _kMinImageFractionSize) /
        (1.0 - _kMinImageFractionSize);

    final readerMode = BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
      bloc: discoveryCardManager,
      builder: (context, state) {
        return ClipRRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxWidth: mediaQuery.size.width,
            child: ReaderMode(
              title: title,
              snippet: snippet,
              imageUri: Uri.parse(imageUrl),
              processHtmlResult: state.output?.processHtmlResult,
              padding: EdgeInsets.only(
                left: R.dimen.unit2,
                right: R.dimen.unit2,
                bottom: R.dimen.unit2,
                top: mediaQuery.size.height * _kMinImageFractionSize,
              ),
              onProcessedHtml: () => _openingAnimation.animateTo(
                _kMinImageFractionSize,
                curve: Curves.fastOutSlowIn,
              ),
              onScroll: (position) => setState(() => _scrollOffset = position),
            ),
          ),
        );
      },
    );

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final maskedImage = Container(
          foregroundDecoration: BoxDecoration(
            gradient: buildGradient(opacity: _openingAnimation.value),
          ),
          child: image,
        );
        final maskedReaderMode = DiscoveryCardFooter(
          title: webResource.title,
          timeToRead: state.output?.timeToRead ?? '',
          url: webResource.url,
          provider: webResource.provider,
          datePublished: webResource.datePublished,
          onLikePressed: () => actionsManager.likeDocument(widget.document),
          onDislikePressed: () =>
              actionsManager.dislikeDocument(widget.document),
          fractionSize: normalizedValue,
        );

        return Stack(
          children: [
            Positioned.fill(child: readerMode),
            Positioned(
              top: -_scrollOffset * (1.0 - normalizedValue),
              left: 0,
              right: 0,
              child: Container(
                height: constraints.maxHeight * _openingAnimation.value,
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [maskedImage, maskedReaderMode],
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
        onWillPop: () async {
          await _openingAnimation.animateTo(
            1.0,
            curve: Curves.fastOutSlowIn,
          );

          widget.onDiscard?.call();

          return false;
        },
        child: body,
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
          child: super.buildFromState(context, state, image),
        ),
      );
}

class DragBackRecognizer extends HorizontalDragGestureRecognizer {
  final AnimationControllerBuilder animationControllerBuilder;
  final DragCallback onDrag;
  final VoidCallback? onDiscard;

  AnimationController? _animationController;
  double _distance = .0;
  int? _lastPointer;

  double get distance => _distance;

  DragBackRecognizer({
    required this.animationControllerBuilder,
    required this.onDrag,
    this.onDiscard,
    Object? debugOwner,
  }) : super(debugOwner: debugOwner) {
    onStart = onDragStart;
    onUpdate = onDragUpdate;
    onEnd = onDragEnd;
    onCancel = onDragCancel;
  }

  @override
  void dispose() {
    _animationController?.stop(canceled: true);
    _animationController?.dispose();

    super.dispose();
  }

  @override
  void addPointer(PointerDownEvent event) {
    _lastPointer = event.pointer;

    super.addPointer(event);
  }

  void onDragStart(DragStartDetails event) {
    _distance = .0;

    onDrag(_distance);

    _animationController?.stop(canceled: true);
    _animationController?.dispose();
  }

  void onDragUpdate(DragUpdateDetails event) {
    _distance += event.delta.dx;

    if (_distance > DiscoveryCard.dragThreshold) {
      _distance = 0;

      HapticFeedback.mediumImpact();

      stopTrackingPointer(_lastPointer!);

      onDiscard?.call();
    }

    onDrag(_distance);
  }

  void onDragEnd(DragEndDetails? event) async {
    final velocity = event?.primaryVelocity ?? .0;

    stopTrackingPointer(_lastPointer!);

    if (velocity >= _kFlingVelocity) {
      _distance = 0;

      return onDiscard?.call();
    }

    if (_distance <= DiscoveryCard.dragThreshold) {
      final controller = _animationController = animationControllerBuilder();

      controller.addListener(() {
        onDrag(_distance * (1.0 - controller.value));
      });

      await controller.animateTo(1.0, curve: _kSnapBackCurve);

      controller.dispose();

      _animationController = null;
    }
  }

  void onDragCancel() => onDragEnd(null);
}

class DiscoveryCardController extends ChangeNotifier {
  final AnimationController _animationController;

  DiscoveryCardController(this._animationController);

  Future<void> animateToClose() async {
    await _animationController.animateTo(
      1.0,
      curve: Curves.fastOutSlowIn,
    );
  }
}
