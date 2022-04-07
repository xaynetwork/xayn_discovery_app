import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/base_painter.dart';

class TraversalPainter extends BaseAnimationPainter {
  final double imageSizeOverflow;

  TraversalPainter({
    required ui.Image image,
    required Color shadowColor,
    required double animationValue,
    required this.imageSizeOverflow,
  }) : super(
          image: image,
          shadowColor: shadowColor,
          animationValue: animationValue,
        );

  @override
  void paintMedia(ui.Canvas canvas, ui.Image image, ui.Size size, Rect rect) {
    final destination = Rect.fromLTWH(
        rect.width + imageSizeOverflow * animationValue,
        .0,
        rect.width,
        rect.height);

    canvas.drawImageRect(image, destination, rect, Paint());
  }

  @override
  bool shouldRepaint(TraversalPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      oldDelegate.imageSizeOverflow != imageSizeOverflow;
}
