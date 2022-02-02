import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';

/// When long pressing the wrapped widget move/animate it to the center
/// of the screen and add a transparent layer as background.
/// It uses the [Hero] widget for the animation.
///
/// Input parameters:
/// [child] the widget to animate
/// [onAnimationDone] callback called after the route has been pushed.
///
/// Please note: since this widget uses the [onLongPressed] callback provided
/// by the [GestureDetector], the child passed to this widget must not have its on
/// [onLongPressed] enabled, otherwise the animation is not triggered.
class CardWidgetTransition extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAnimationDone;
  const CardWidgetTransition({
    required this.child,
    this.onAnimationDone,
    Key? key,
  }) : super(
          key: key,
        );

  @override
  _CardWidgetTransitionState createState() => _CardWidgetTransitionState();
}

class _CardWidgetTransitionState extends State<CardWidgetTransition> {
  late final GlobalKey itemKey;
  late Size childSize;

  @override
  void initState() {
    itemKey = GlobalKey();
    childSize = const Size(
      CardWidgetData.cardWidth,
      CardWidgetData.cardHeight,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: itemKey,
        child: Hero(
          tag: itemKey.toString(),
          child: widget.child,
          placeholderBuilder: (_, __, widget) => widget,
        ),
        onLongPress: () => _animate(),
      );

  void _animate() {
    _calculateChildSize();
    final hero = Hero(
      tag: itemKey.toString(),

      /// Needed for adding an opaque background to the card
      child: Container(
        decoration: BoxDecoration(
          borderRadius: R.styles.roundBorder1_5,
          color: Colors.white,
        ),
        child: SizedBox(
          height: childSize.height,
          width: childSize.width,
          child: widget.child,
        ),
      ),
    );
    final scaffold = Scaffold(
      backgroundColor: R.colors.bottomSheetBarrierColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
          ),
          hero,
        ],
      ),
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => scaffold,
      ),
    );
    if (widget.onAnimationDone != null) {
      widget.onAnimationDone!();
    }
  }

  _calculateChildSize() {
    final currentContext = itemKey.currentContext;
    if (currentContext == null) return;
    final renderBox = currentContext.findRenderObject() as RenderBox;
    final size = renderBox.size;
    setState(() {
      childSize = size;
    });
  }
}
