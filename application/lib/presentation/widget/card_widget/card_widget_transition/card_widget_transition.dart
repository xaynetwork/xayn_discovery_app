import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CardWidgetTransition extends StatelessWidget {
  final CardWidgetTransitionArgs args;

  const CardWidgetTransition({
    Key? key,
    required this.args,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final hero = Hero(
      tag: args.heroTag,

      /// Needed for adding an opaque background to the card
      child: Container(
        decoration: BoxDecoration(
          borderRadius: R.styles.roundBorder1_5,
          color: Colors.white,
        ),
        child: SizedBox(
          height: args.childSize.height,
          width: args.childSize.width,
          child: args.child,
        ),
      ),
    );
    final scaffold = Scaffold(
      backgroundColor: R.colors.bottomSheetBarrierColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: args.onTransparentLayerTap,
          ),
          hero,
        ],
      ),
    );
    return scaffold;
  }
}

@immutable
class CardWidgetTransitionArgs {
  final Widget child;
  final Size childSize;
  final String heroTag;
  final VoidCallback onTransparentLayerTap;

  const CardWidgetTransitionArgs(
      {required this.child,
      required this.childSize,
      required this.heroTag,
      required this.onTransparentLayerTap});
}
