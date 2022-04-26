import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/widget/illustration_container.dart';

mixin IllustrationMixin<T extends StatefulWidget> on State<T> {
  String get illustrationAssetName;

  @override
  @mustCallSuper
  Widget build(BuildContext context) => IllustrationContainer.asset(
        illustrationAssetName,
        child: buildChild(context),
      );

  Widget buildChild(BuildContext context);
}
