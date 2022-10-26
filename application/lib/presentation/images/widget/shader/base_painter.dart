import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class BaseStaticPainter extends CustomPainter {
  final ui.Image? _image;

  BaseStaticPainter({
    ui.Image? image,
  }) : _image = image;

  @override
  @protected
  void paint(ui.Canvas canvas, ui.Size size) {
    final image = _image;
    final rect = ui.Rect.fromLTWH(
      .0,
      .0,
      size.width.ceilToDouble(),
      size.height.ceilToDouble(),
    );

    if (image != null) paintMedia(canvas, image, rect);
  }

  @override
  bool shouldRepaint(covariant BaseStaticPainter oldDelegate) => false;

  void paintMedia(ui.Canvas canvas, ui.Image image, Rect rect);
}

abstract class BaseAnimationPainter extends BaseStaticPainter {
  final double _animationValue;

  BaseAnimationPainter({
    ui.Image? image,
    required double animationValue,
    Color? shadowColor,
  })  : _animationValue = animationValue,
        super(
          image: image,
        );

  double get animationValue => _animationValue;

  @override
  bool shouldRepaint(covariant BaseAnimationPainter oldDelegate) =>
      oldDelegate._animationValue != animationValue;
}
