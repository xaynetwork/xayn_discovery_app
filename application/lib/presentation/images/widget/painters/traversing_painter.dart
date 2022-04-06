import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:xayn_discovery_app/presentation/images/widget/painters/base_painter.dart';

class TraversingPainter extends BasePainter {
  final Offset offset;

  TraversingPainter({
    required ui.Image image,
    required Color shadowColor,
    required this.offset,
  }) : super(
          image: image,
          shadowColor: shadowColor,
        );

  @override
  void paintMedia(ui.Canvas canvas, ui.Image image, ui.Size size, Rect rect) =>
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(
            offset.dx, rect.top, rect.width - offset.dx, rect.height),
        image: image,
        fit: BoxFit.fitHeight,
      );

  @override
  bool shouldRepaint(TraversingPainter oldDelegate) {
    return oldDelegate.offset.dx != offset.dx;
  }
}
