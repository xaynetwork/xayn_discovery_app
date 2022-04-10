import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_painter.dart';

class StaticPainter extends BaseStaticPainter {
  late final Paint _paint = Paint();

  StaticPainter({
    required ui.Image image,
    Color? shadowColor,
  }) : super(
          image: image,
          shadowColor: shadowColor,
        );

  @override
  void paintMedia(ui.Canvas canvas, ui.Image image, Rect rect) {
    final outputSize = rect.size;
    final inputSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(BoxFit.cover, inputSize, outputSize);
    final sourceSize = fittedSizes.source;
    final destinationSize = fittedSizes.destination;
    final halfWidthDelta = (outputSize.width - destinationSize.width) / 2.0;
    final halfHeightDelta = (outputSize.height - destinationSize.height) / 2.0;
    final dx = halfWidthDelta + halfWidthDelta;
    final dy = halfHeightDelta + halfHeightDelta;
    final destinationPosition = rect.topLeft.translate(dx, dy);
    final destinationRect = destinationPosition & destinationSize;
    final sourceRect = Alignment.center.inscribe(
      sourceSize,
      Offset.zero & inputSize,
    );

    canvas.drawImageRect(image, sourceRect, destinationRect, _paint);
  }
}
