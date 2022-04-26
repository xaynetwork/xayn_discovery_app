import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/widget/illustration.dart';

class IllustrationContainer extends StatelessWidget {
  final Widget child;
  final String assetName;
  final VoidCallback? onFinished;
  final double? width;
  final double? height;

  const IllustrationContainer.asset(
    this.assetName, {
    Key? key,
    required this.child,
    this.onFinished,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final illustration = Illustration.asset(
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
