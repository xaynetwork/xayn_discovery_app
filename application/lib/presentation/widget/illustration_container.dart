import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/widget/illustration.dart';

class IllustrationContainer extends StatelessWidget {
  final Widget child;
  final String assetName;
  final VoidCallback? onFinished;

  const IllustrationContainer.asset(
    this.assetName, {
    Key? key,
    required this.child,
    this.onFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final illustration = Illustration.asset(
      assetName,
      onFinished: onFinished,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        illustration,
        Expanded(child: child),
      ],
    );
  }
}
