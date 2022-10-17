import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double kBezierMinHeight = 10.0;
const double kBezierMaxHeight = 45.0;
const double kArcBezierSize = 1.0;

class ForegroundPainter extends CustomPainter {
  final double fractionSize;
  final double bezierHeight;
  final Color color;

  ForegroundPainter({
    required this.fractionSize,
    required this.bezierHeight,
    required this.color,
  }) {
    assert(bezierHeight >= kBezierMinHeight && bezierHeight <= kBezierMaxHeight,
        'bezierHeight must be with the range of: [$kBezierMinHeight, $kBezierMaxHeight]');
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fractionHeight = .4 - (fractionSize * .25);
    final actualHeight = size.height * fractionHeight;
    final diffHeight = size.height - actualHeight;
    const arcRightDelta = 20.0;
    const arcLeftDelta = 8.0;
    final path = Path()
      // main bg section
      ..moveTo(.0, diffHeight)
      ..lineTo(.0, size.height + 1.0)
      ..lineTo(size.width, size.height + 1.0)
      ..lineTo(size.width, diffHeight)
      ..quadraticBezierTo(size.width / 2,
          size.height - actualHeight - bezierHeight, .0, diffHeight)
      // top arc path section
      ..moveTo(size.width, diffHeight - arcRightDelta)
      ..quadraticBezierTo(
          size.width / 2,
          size.height - actualHeight - bezierHeight - arcLeftDelta,
          .0,
          diffHeight - arcLeftDelta)
      ..lineTo(.0, diffHeight - arcLeftDelta - kArcBezierSize)
      ..quadraticBezierTo(
          size.width / 2,
          size.height -
              actualHeight -
              bezierHeight -
              arcLeftDelta -
              kArcBezierSize,
          size.width,
          diffHeight - arcRightDelta - kArcBezierSize)
      ..lineTo(size.width, diffHeight - arcRightDelta);

    canvas.drawPath(
      path,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant ForegroundPainter oldDelegate) =>
      oldDelegate.fractionSize != fractionSize;
}
