import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

class AnimationPlayer extends StatefulWidget {
  final String asset;
  final bool isLooping;
  final VoidCallback? onFinished;
  final double? width;
  final double? height;

  const AnimationPlayer.asset(
    this.asset, {
    Key? key,
    this.isLooping = true,
    this.onFinished,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimationPlayerState();
}

class _AnimationPlayerState extends State<AnimationPlayer>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_animationStatusListener);

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // avoid animations in test
    if (EnvironmentHelper.kIsInTest) return Container();

    return Lottie.asset(
      widget.asset,
      controller: _controller,
      width: widget.width,
      height: widget.height,
      onLoaded: (composition) {
        _controller!
          ..duration = composition.duration
          ..forward();
      },
    );
  }

  void _animationStatusListener(AnimationStatus status) {
    final onFinished = widget.onFinished;

    switch (status) {
      case AnimationStatus.completed:
        onFinished?.call();

        if (widget.isLooping) {
          _controller!.forward(from: .0);
        }

        break;
      default:
        break;
    }
  }
}
