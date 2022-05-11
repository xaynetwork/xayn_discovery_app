import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

const double _kWidth = 200.0;
const double _kHeight = 200.0;

class AnimationPlayer extends StatefulWidget {
  final String asset;
  final bool isLooping;
  final bool playsFromStart;
  final VoidCallback? onFinished;
  final double? width;
  final double? height;

  const AnimationPlayer.asset(
    this.asset, {
    Key? key,
    this.isLooping = true,
    this.playsFromStart = true,
    this.onFinished,
    this.width = _kWidth,
    this.height = _kHeight,
  }) : super(key: key);

  const AnimationPlayer.assetUnrestrictedSize(
    this.asset, {
    Key? key,
    this.isLooping = true,
    this.playsFromStart = true,
    this.onFinished,
  })  : width = null,
        height = null,
        super(key: key);

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
    if (EnvironmentHelper.kIsInTest) {
      widget.onFinished?.call();

      return Container();
    }

    final millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    return Lottie.asset(
      widget.asset,
      controller: _controller,
      width: widget.width,
      height: widget.height,
      onLoaded: (composition) {
        final compositionTimeMs = composition.duration.inMilliseconds;
        final offset =
            (millisecondsSinceEpoch % compositionTimeMs) / compositionTimeMs;

        _controller!
          ..value = widget.playsFromStart ? .0 : offset
          ..duration = composition.duration
          ..forward();
      },
    );
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onFinished?.call();

      if (widget.isLooping) {
        _controller!.forward(from: .0);
      }
    }
  }
}
