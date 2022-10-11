import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/foreground/foreground_painter.dart';

class Arc extends StatelessWidget {
  final Widget child;

  /// value between [.0, 1.0]
  /// this indicates how much the Arc covers:
  /// - .0 is minimal coverage
  /// - 1.0 is maximal coverage
  final double fractionSize;

  const Arc({
    Key? key,
    required this.child,
    this.fractionSize = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foreground = CustomPaint(
      painter: ForegroundPainter(
        fractionSize: fractionSize,
        bezierHeight: 45.0,
      ),
    );

    return LayoutBuilder(
        builder: (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  bottom: constraints.maxHeight / 3 * (1.0 - fractionSize),
                  child: child,
                ),
                Positioned.fill(child: foreground),
              ],
            ));
  }
}
