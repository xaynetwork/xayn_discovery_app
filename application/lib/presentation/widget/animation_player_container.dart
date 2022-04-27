import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

const double _kWidth = 200.0;
const double _kHeight = 200.0;

class AnimationPlayerContainer extends StatelessWidget {
  final Widget child;
  final String assetName;
  final VoidCallback? onFinished;
  final double width;
  final double height;

  const AnimationPlayerContainer.asset(
    this.assetName, {
    Key? key,
    required this.child,
    this.onFinished,
    this.width = _kWidth,
    this.height = _kHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final illustration = AnimationPlayer.asset(
      assetName,
      width: width,
      height: height,
      onFinished: onFinished,
    );

    return Column(
      children: [
        Expanded(child: illustration),
        child,
      ],
    );
  }
}
