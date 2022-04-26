import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

class Illustration extends StatefulWidget {
  final String asset;
  final bool isLooping;
  final VoidCallback? onFinished;
  final double? width;
  final double? height;

  const Illustration.asset(
    this.asset, {
    Key? key,
    this.isLooping = true,
    this.onFinished,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IllustrationState();
}

class _IllustrationState extends State<Illustration>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener(_animationStatusListener);
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
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
        _controller
          ..duration = composition.duration
          ..forward();
      },
    );
  }

  void _animationStatusListener(AnimationStatus status) {
    final onFinished = widget.onFinished;

    if (status == AnimationStatus.completed && onFinished != null) {
      onFinished();
    }
  }
}
