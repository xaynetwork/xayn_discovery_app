import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double kBezierMinHeight = 10.0;
const double kBezierMaxHeight = 45.0;
const double kArcBezierSize = 1.0;

class ForegroundPainter extends CustomPainter {
  final double fractionSize;
  final double bezierHeight;
  final Color color;
  final ArcVariation arcVariations;

  ForegroundPainter({
    required this.fractionSize,
    required this.bezierHeight,
    required this.color,
    required this.arcVariations,
  }) {
    assert(bezierHeight >= kBezierMinHeight && bezierHeight <= kBezierMaxHeight,
        'bezierHeight must be with the range of: [$kBezierMinHeight, $kBezierMaxHeight]');
  }

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
        getPath(size, arcVariations),
        Paint()..color = color,
      );

  @override
  bool shouldRepaint(covariant ForegroundPainter oldDelegate) =>
      oldDelegate.fractionSize != fractionSize;

  Path getDownwardsPath(
    Size size,
    double arcRightDelta,
    double arcLeftDelta,
    double fractionSize,
  ) {
    final fractionHeight = .4 - (fractionSize * .4);
    final actualHeight = size.height * fractionHeight;
    final diffHeight = size.height - actualHeight;
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
    return path;
  }

  Path getUpwardsPath(
    Size size,
    double arcRightDelta,
    double arcLeftDelta,
    double fractionSize,
  ) {
    final fractionHeight = .4 - (fractionSize * .4);
    final actualHeight = size.height * fractionHeight;
    final diffHeight = size.height - actualHeight - bezierHeight;
    final path = Path()
      // main bg section
      ..moveTo(.0, diffHeight)
      ..lineTo(.0, size.height + 1.0)
      ..lineTo(size.width, size.height + 1.0)
      ..lineTo(size.width, diffHeight)
      ..quadraticBezierTo(
          size.width / 2, size.height - actualHeight, .0, diffHeight)
      // top arc path section
      ..moveTo(size.width, diffHeight - arcRightDelta)
      ..quadraticBezierTo(
        size.width / 2,
        diffHeight - arcLeftDelta + 20,
        .0,
        diffHeight - arcLeftDelta,
      )
      ..lineTo(.0, diffHeight - arcLeftDelta - kArcBezierSize)
      ..quadraticBezierTo(
        size.width / 2,
        diffHeight - arcLeftDelta - kArcBezierSize + 20,
        size.width,
        diffHeight - arcRightDelta - kArcBezierSize,
      )
      ..lineTo(size.width, diffHeight - arcRightDelta);
    return path;
  }

  Path getPath(Size size, ArcVariation arcVariations) {
    switch (arcVariations) {
      case ArcVariation.v0:
      case ArcVariation.v1:
        return getDownwardsPath(size, 40, 8, fractionSize);
      case ArcVariation.v2:
        return getDownwardsPath(size, 20, 20, fractionSize);
      case ArcVariation.v3:
        return getDownwardsPath(size, 20, 8, fractionSize);
      case ArcVariation.v4:
        return getDownwardsPath(size, 8, 20, fractionSize);
      case ArcVariation.v5:
        return getUpwardsPath(size, 60, 8, fractionSize);
      case ArcVariation.v6:
        return getUpwardsPath(size, 20, 12, fractionSize);
      case ArcVariation.v7:
        return getUpwardsPath(size, 20, 8, fractionSize);
      case ArcVariation.v8:
        return getUpwardsPath(size, 8, 12, fractionSize);
    }
  }
}

enum ArcVariation { v0, v1, v2, v3, v4, v5, v6, v7, v8 }

ArcVariation getRandomArcVariation() =>
    ArcVariation.values.elementAt(Random().nextInt(ArcVariation.values.length));
