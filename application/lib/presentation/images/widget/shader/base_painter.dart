import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class BaseStaticPainter extends CustomPainter {
  final ui.Image _image;
  final List<Color> _gradientColors;
  final bool _hasGradient;

  BaseStaticPainter({
    required ui.Image image,
    Color? shadowColor,
  })  : _image = image,
        _hasGradient = shadowColor != null,
        _gradientColors = [
          shadowColor?.withAlpha(120) ?? Colors.transparent,
          shadowColor?.withAlpha(40) ?? Colors.transparent,
          shadowColor?.withAlpha(255) ?? Colors.transparent,
          shadowColor?.withAlpha(255) ?? Colors.transparent,
        ];

  @override
  @protected
  void paint(ui.Canvas canvas, ui.Size size) {
    final rect = ui.Rect.fromLTWH(.0, .0, size.width, size.height);

    canvas.save();

    paintMedia(canvas, _image, rect);

    if (_hasGradient) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            size.topCenter(Offset.zero),
            size.bottomCenter(Offset.zero),
            _gradientColors,
            const [0, 0.15, 0.8, 1],
          ),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BaseStaticPainter oldDelegate) => false;

  void paintMedia(ui.Canvas canvas, ui.Image image, Rect rect);
}

abstract class BaseAnimationPainter extends BaseStaticPainter {
  final double _animationValue;

  BaseAnimationPainter({
    required ui.Image image,
    required double animationValue,
    Color? shadowColor,
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
