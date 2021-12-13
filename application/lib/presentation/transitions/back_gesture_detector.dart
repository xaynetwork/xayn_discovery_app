import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class BackGestureDetector<T> extends StatefulWidget {
  final Widget child;
  final NavigatorState navigator;

  const BackGestureDetector({
    Key? key,
    required this.navigator,
    required this.child,
  }) : super(key: key);

  @override
  _BackGestureDetectorState<T> createState() => _BackGestureDetectorState<T>();
}

class _BackGestureDetectorState<T> extends State<BackGestureDetector<T>>
    with TickerProviderStateMixin {
  _BackGestureController<T>? _backGestureController;

  late final HorizontalDragGestureRecognizer _recognizer;
  late final AnimationController _animationController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();

    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animationController.addListener(() {
      setState(() {
        _scale = 1.0 - _animationController.value;
      });
    });
  }

  @override
  void dispose() {
    _recognizer.dispose();
    _animationController.dispose();

    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_backGestureController == null);

    widget.navigator.didStartUserGesture();

    _backGestureController = _BackGestureController(
        navigator: widget.navigator, controller: _animationController);
  }

  void _handleDragUpdate(DragUpdateDetails details) async {
    final didPop = await _backGestureController!.dragUpdate(
        _convertToLogical(details.primaryDelta! / context.size!.width));

    if (didPop) _backGestureController = null;
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    if (_backGestureController == null) return;

    _backGestureController!.dragEnd(_convertToLogical(
        details.velocity.pixelsPerSecond.dx / context.size!.width));
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    // This can be called even if start is not called, paired with the "down" event
    // that we don't consider here.
    //_backGestureController?.dragEnd(0.0);
    //_backGestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _recognizer.addPointer(event);
  }

  double _convertToLogical(double value) {
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        return -value;
      case TextDirection.ltr:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    return LayoutBuilder(builder: (context, constraints) {
      // For devices with notches, the drag area needs to be larger on the side
      // that has the notch.
      double dragAreaWidth = Directionality.of(context) == TextDirection.ltr
          ? MediaQuery.of(context).padding.left
          : MediaQuery.of(context).padding.right;
      dragAreaWidth = max(dragAreaWidth, constraints.maxWidth / 2);

      return Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Positioned.fill(child: ColoredBox(color: R.colors.cardBackground)),
          Transform.scale(
            scale: _scale,
            child: widget.child,
          ),
          PositionedDirectional(
            start: 0.0,
            width: dragAreaWidth,
            top: 0.0,
            bottom: 0.0,
            child: Listener(
              onPointerDown: _handlePointerDown,
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      );
    });
  }
}

class _BackGestureController<T> {
  _BackGestureController({
    required this.navigator,
    required this.controller,
  });

  final NavigatorState navigator;
  final AnimationController controller;
  bool _acceptPointers = true;

  Future<bool> dragUpdate(double delta) async {
    if (!_acceptPointers) return false;

    controller.value += delta;

    if (controller.value > .3) {
      _acceptPointers = false;

      await _easeBackOut();

      navigator.didStopUserGesture();
      navigator.pop();

      return true;
    }

    return false;
  }

  void dragEnd(double velocity) async {
    if (!_acceptPointers) return;

    await _easeBackOut();

    navigator.didStopUserGesture();
  }

  Future<void> _easeBackOut({double end = .0}) => controller.animateTo(
        end,
        duration: R.durations.tweenOutReaderModeDuration,
        curve: Curves.fastOutSlowIn,
      );
}
