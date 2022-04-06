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
  void paintMedia(ui.Canvas canvas, ui.Image image, ui.Size size, Rect rect) {
    final destination =
        Rect.fromLTWH(rect.width + offset.dx, .0, rect.width, rect.height);

    canvas.drawImageRect(image, destination, rect, Paint());
  }

  @override
  bool shouldRepaint(TraversingPainter oldDelegate) {
    return oldDelegate.offset.dx != offset.dx;
  }
}
