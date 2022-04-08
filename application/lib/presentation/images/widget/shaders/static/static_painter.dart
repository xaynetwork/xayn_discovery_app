import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/base_painter.dart';

class StaticPainter extends BaseStaticPainter {
  StaticPainter({
    required ui.Image image,
    Color? shadowColor,
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
        fit: BoxFit.cover,
      );
}
