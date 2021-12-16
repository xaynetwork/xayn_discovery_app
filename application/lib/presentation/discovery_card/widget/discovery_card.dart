import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_footer.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';

const double kDragThreshold = 200.0;
const Duration kSnapBackDuration = Duration(milliseconds: 450);
const Curve kSnapBackCurve = Curves.elasticOut;
const double kMinImageFractionSize = .2;

typedef DragCallback = void Function(double);
typedef AnimationControllerBuilder = AnimationController Function();

class DiscoveryCard extends DiscoveryCardBase {
  final DragCallback? onDrag;
  final VoidCallback? onDiscard;

  const DiscoveryCard({
    Key? key,
    required bool isPrimary,
    required Document document,
    DiscoveryCardManager? discoveryCardManager,
    ImageManager? imageManager,
    this.onDiscard,
    this.onDrag,
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

class _DiscoveryCardState extends DiscoveryCardBaseState<DiscoveryCard>
    with TickerProviderStateMixin {
  late final AnimationController _openingAnimation;
  late final DragBackRecognizer _recognizer;
  late final DragCallback _onDrag;

  @override
  void initState() {
    super.initState();

    _onDrag = (distance) {
      _openingAnimation.value =
          (1.0 - (kDragThreshold - distance) / kDragThreshold)
              .clamp(kMinImageFractionSize, 1.0);

      widget.onDrag?.call(distance);
    };

    _openingAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..value = 1.0;

    _openingAnimation.addListener(() {
      setState(() {});
    });

    _recognizer = DragBackRecognizer(
      debugOwner: this,
      onDrag: _onDrag,
      onDiscard: widget.onDiscard,
      animationControllerBuilder: () =>
          AnimationController(vsync: this, duration: kSnapBackDuration),
    );
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
    final opacity = (_openingAnimation.value - kMinImageFractionSize) /
        (1.0 - kMinImageFractionSize);

    buildFooter(double? maxHeight) => OverflowBox(
          maxWidth: mediaQuery.size.width,
          maxHeight: maxHeight,
          child: Opacity(
              opacity: opacity,
              child: DiscoveryCardFooter(
                title: webResource.title,
                url: webResource.url,
                provider: webResource.provider,
                datePublished: webResource.datePublished,
                onLikePressed: () =>
                    actionsManager.likeDocument(widget.document),
                onDislikePressed: () =>
                    actionsManager.dislikeDocument(widget.document),
              )),
        );

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
              processHtmlResult: state.result,
              onProcessedHtml: () => _openingAnimation.animateTo(
                kMinImageFractionSize,
                curve: Curves.fastOutSlowIn,
              ),
            ),
          ),
        );
      },
    );
    final body = LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              height: constraints.maxHeight * _openingAnimation.value,
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  Container(
                      foregroundDecoration: BoxDecoration(
                        gradient:
                            buildGradient(opacity: _openingAnimation.value),
                      ),
                      child: image),
                  ClipRect(
                    child: OverflowBox(
                      maxWidth: mediaQuery.size.width,
                      maxHeight: constraints.maxHeight,
                      child: Opacity(
                        opacity: opacity,
                        child: buildFooter(constraints.maxHeight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: readerMode,
            ),
          ],
        );
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Listener(
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
        ),
      ),
    );
  }
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

    if (_distance > kDragThreshold) {
      _distance = 0;

      HapticFeedback.mediumImpact();

      stopTrackingPointer(_lastPointer!);

      onDiscard?.call();
    }

    onDrag(_distance);
  }

  void onDragEnd(DragEndDetails event) async {
    if (_distance <= kDragThreshold) {
      final controller = _animationController = animationControllerBuilder();

      stopTrackingPointer(_lastPointer!);

      controller.addListener(() {
        onDrag(_distance * (1.0 - controller.value));
      });

      await controller.animateTo(1.0, curve: kSnapBackCurve);

      controller.dispose();

      _animationController = null;
    }
  }
}
