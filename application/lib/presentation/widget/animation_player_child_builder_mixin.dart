import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player_container.dart';

mixin AnimationPlayerChildBuilderMixin on StatelessWidget {
  String get illustrationAssetName;

  @override
  @mustCallSuper
  Widget build(BuildContext context) => AnimationPlayerContainer.asset(
        illustrationAssetName,
        child: buildChild(context),
      );

  Widget buildChild(BuildContext context);
}

mixin AnimationPlayerChildBuilderStateMixin<T extends StatefulWidget>
    on State<T> {
  String get illustrationAssetName;

  @override
  @mustCallSuper
  Widget build(BuildContext context) => AnimationPlayerContainer.asset(
        illustrationAssetName,
        child: buildChild(context),
      );

  Widget buildChild(BuildContext context);
}
