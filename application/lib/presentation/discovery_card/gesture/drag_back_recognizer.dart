import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// signature for building an [AnimationController]
typedef AnimationControllerBuilder = AnimationController Function();

/// callback which triggers on drag updates, and passes the dragged distance down.
typedef DragCallback = void Function(double);

class DragBackRecognizer extends HorizontalDragGestureRecognizer {
  final AnimationControllerBuilder animationControllerBuilder;
  final DragCallback onDrag;
  final VoidCallback? onDiscard;
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

    if (_distance > threshold) {
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

    if (velocity >= R.animations.flingVelocity) {
      _distance = 0;

      onDiscard?.call();
      onDrag(_distance);
    } else if (_distance <= threshold) {
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
