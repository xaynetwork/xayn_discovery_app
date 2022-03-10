import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget_transition/card_widget_transition.dart';

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
class CardWidgetTransitionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAnimationDone;
  final VoidCallback? onLongPress;
  const CardWidgetTransitionWrapper({
    required this.child,
    this.onAnimationDone,
    this.onLongPress,
    Key? key,
  }) : super(
          key: key,
        );

  @override
  _CardWidgetTransitionWrapperState createState() =>
      _CardWidgetTransitionWrapperState();
}

class _CardWidgetTransitionWrapperState
    extends State<CardWidgetTransitionWrapper> {
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
      onLongPress: () {
        widget.onLongPress?.call();
        _animate();
      });

  void _animate() {
    _calculateChildSize();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => CardWidgetTransition(
          args: CardWidgetTransitionArgs(
            child: widget.child,
            childSize: childSize,
            heroTag: itemKey.toString(),
            onTransparentLayerTap: () => Navigator.pop(context),
          ),
        ),
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
