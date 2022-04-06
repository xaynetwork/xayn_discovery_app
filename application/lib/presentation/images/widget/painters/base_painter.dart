import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

abstract class BasePainter extends CustomPainter {
  final ui.Image _image;
  final Color _shadowColor;

  BasePainter({
    required ui.Image image,
    required Color shadowColor,
  })  : _image = image,
        _shadowColor = shadowColor;

  @override
  @protected
  void paint(ui.Canvas canvas, ui.Size size) {
    final rect = ui.Rect.fromLTWH(.0, .0, size.width, size.height);

    paintMedia(canvas, _image, size, rect);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          size.topCenter(Offset.zero),
          size.bottomCenter(Offset.zero),
          [
            _shadowColor.withAlpha(120),
            _shadowColor.withAlpha(40),
            _shadowColor.withAlpha(255),
            _shadowColor.withAlpha(255),
          ],
          const [0, 0.15, 0.8, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void paintMedia(ui.Canvas canvas, ui.Image image, ui.Size size, Rect rect);
}
