import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_painter.dart';

class ZoomPainter extends BaseAnimationPainter {
  late final _paint = Paint();

  ZoomPainter({
    required ui.Image image,
    required double animationValue,
    Color? shadowColor,
  }) : super(
          image: image,
          shadowColor: shadowColor,
          animationValue: animationValue,
        );

  @override
  void paintMedia(ui.Canvas canvas, ui.Image image, Rect rect) {
    final imageAr = image.width / image.height;
    final rectAr = rect.width / rect.height;
    final ar = rectAr / imageAr;
    final f = ((animationValue - .5).abs() + 1.0);
    final dw = image.width.toDouble() * ar / f;
    final dh = image.height.toDouble() / f;
    final src = Rect.fromLTWH(
      image.width * .5 - dw * .5,
      image.height * .5 - dh * .5,
      dw,
      dh,
    );

    canvas.drawImageRect(image, src, rect, _paint);
  }
}
