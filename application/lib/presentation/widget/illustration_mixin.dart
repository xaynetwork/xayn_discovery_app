import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/widget/illustration_container.dart';

const double _kWidth = 200.0;
const double _kHeight = 200.0;

mixin IllustrationMixin<T extends StatefulWidget> on State<T> {
  String get illustrationAssetName;

  @override
  @mustCallSuper
  Widget build(BuildContext context) => IllustrationContainer.asset(
        illustrationAssetName,
        child: buildChild(context),
        width: _kWidth,
        height: _kHeight,
      );

  Widget buildChild(BuildContext context);
}
