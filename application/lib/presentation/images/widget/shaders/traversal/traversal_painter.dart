import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/base_painter.dart';

class TraversalPainter extends BaseAnimationPainter {
  TraversalPainter({
    required ui.Image image,
    required double animationValue,
    Color? shadowColor,
  }) : super(
          image: image,
          shadowColor: shadowColor,
          animationValue: animationValue,
        );

  @override
  void paintMedia(ui.Canvas canvas, ui.Image image, ui.Size size, Rect rect) {
    final scale = image.height / rect.height;
    final dx = image.width - rect.width;
    final tx = dx * animationValue;
    final pos = scale < 1.0 ? tx * scale : tx / scale;
    final src = Rect.fromLTWH(
      pos,
      .0,
      rect.width * scale,
      rect.height * scale,
    );

    canvas.drawImageRect(image, src, rect, Paint());
  }
}
