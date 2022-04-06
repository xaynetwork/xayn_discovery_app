import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:xayn_discovery_app/presentation/images/widget/painters/base_painter.dart';

class StaticPainter extends BasePainter {
  StaticPainter({
    required ui.Image image,
    required Color shadowColor,
  }) : super(
          image: image,
          shadowColor: shadowColor,
        );

  @override
  void paintMedia(ui.Canvas canvas, ui.Image image, ui.Size size, Rect rect) =>
      paintImage(
        canvas: canvas,
        rect: rect,
        image: image,
        fit: BoxFit.fitHeight,
      );
}
