import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/traversal/traversal_painter.dart';

class TraversalShader extends BaseAnimationShader {
  const TraversalShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    Color? shadowColor,
    bool? rendersOnlyOnce,
    Curve? curve,
    double? width,
    double? height,
  }) : super(
          key: key,
          bytes: bytes,
          noImageBuilder: noImageBuilder,
          curve: curve,
          width: width,
          height: height,
          shadowColor: shadowColor,
          uri: uri,
          rendersOnlyOnce: rendersOnlyOnce ?? false,
        );

  @override
  State<StatefulWidget> createState() => _TraversalShaderState();
}

class _TraversalShaderState extends BaseAnimationShaderState<TraversalShader> {
  @override
  Widget build(BuildContext context) {
    final srcImage = image;

    if (srcImage == null) return widget.noImageBuilder(context);

    return CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: TraversalPainter(
        image: srcImage,
        animationValue: animationValue,
        shadowColor: widget.shadowColor,
      ),
    );
  }
}
