import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// signature for building an [AnimationController]
typedef AnimationControllerBuilder = AnimationController Function();

/// callback which triggers on drag updates, and passes the dragged distance down.
typedef DragCallback = void Function(double);

/// A special drag recognizer that listens for a horizontal drag gesture, from left-to-right.
/// When the total drag distance exceeds [threshold], then the close animation will play,
/// afterwards, [onDiscard] is triggered to notify that a close can now effectively take place.
///
/// On drag update, the current distance will be passed via [onDrag].
///
/// The closing animation will be requested when applicable, and should be passed via [animationControllerBuilder].
class DragBackRecognizer extends HorizontalDragGestureRecognizer {
  /// a handler which will be called when this recognizer will perform the close animation
  final AnimationControllerBuilder animationControllerBuilder;

  /// will be invoked whenever the drag back gesture updates it's total distance
  final DragCallback onDrag;

  /// will be invoked when the drag threshold is reached, effectively notifying a close can take place
  final VoidCallback? onDiscard;

  /// the amount of (horizontal) pixels that need to be dragged
  /// when over this [threshold], then [onDiscard] will trigger.
  final double threshold;

  AnimationController? _animationController;
  double _distance = .0;
  int? _lastPointer;

  double get distance => _distance;

  DragBackRecognizer({
    required this.animationControllerBuilder,
    required this.onDrag,
    required this.threshold,
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

  /// accept the gesture and start tracking it
  @override
  void addPointer(PointerDownEvent event) {
    _lastPointer = event.pointer;

    super.addPointer(event);
  }

  void onDragStart(DragStartDetails event) {
    // reset the distance value
    _distance = .0;

    // trigger the handler with the initial value
    onDrag(_distance);

    // if we already should have a closing animation controller, dispose it
    _animationController?.stop(canceled: true);
    _animationController?.dispose();
  }

  void onDragUpdate(DragUpdateDetails event) {
    // update the distance
    _distance += event.delta.dx;

    // test if we dragged far enough
    if (_distance > threshold) {
      _distance = 0;

      HapticFeedback.mediumImpact();

      stopTrackingPointer(_lastPointer!);

      // send discard if the threshold was reached
      onDiscard?.call();
    }

    onDrag(_distance);
  }

  void onDragEnd(DragEndDetails? event) async {
    final velocity = event?.primaryVelocity ?? .0;

    stopTrackingPointer(_lastPointer!);

    if (velocity >= R.animations.flingVelocity) {
      // detect a fling, if true, then handle this as a close.
      _distance = 0;

      onDiscard?.call();
      onDrag(_distance);
    } else if (_distance <= threshold) {
      // when not dragged beyond the threshold, then animate back to the starting state.
      final controller = _animationController = animationControllerBuilder();

      controller.addListener(() {
        onDrag(_distance * (1.0 - controller.value));
      });

      await controller.animateTo(1.0, curve: R.animations.snapBackToFeedCurve);

      controller.dispose();

      _animationController = null;
    }
  }

  void onDragCancel() => onDragEnd(null);
}
