import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

abstract class BaseStaticPainter extends CustomPainter {
  final ui.Image _image;
  final Color _shadowColor;
  late final gradientColors = [
    _shadowColor.withAlpha(120),
    _shadowColor.withAlpha(40),
    _shadowColor.withAlpha(255),
    _shadowColor.withAlpha(255),
  ];

  BaseStaticPainter({
    required ui.Image image,
    required Color shadowColor,
  })  : _image = image,
        _shadowColor = shadowColor;

  @override
  @protected
  void paint(ui.Canvas canvas, ui.Size size) {
    final rect = ui.Rect.fromLTWH(.0, .0, size.width, size.height);

    canvas.save();

    paintMedia(canvas, _image, size, rect);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          size.topCenter(Offset.zero),
          size.bottomCenter(Offset.zero),
          gradientColors,
          const [0, 0.15, 0.8, 1],
        ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BaseStaticPainter oldDelegate) => false;

  void paintMedia(ui.Canvas canvas, ui.Image image, ui.Size size, Rect rect);
}

abstract class BaseAnimationPainter extends BaseStaticPainter {
  final double _animationValue;

  BaseAnimationPainter({
    required ui.Image image,
    required Color shadowColor,
    required double animationValue,
  })  : _animationValue = animationValue,
        super(
          image: image,
          shadowColor: shadowColor,
        );

  double get animationValue => _animationValue;

  @override
  bool shouldRepaint(covariant BaseAnimationPainter oldDelegate) =>
      oldDelegate._animationValue != animationValue;
}
