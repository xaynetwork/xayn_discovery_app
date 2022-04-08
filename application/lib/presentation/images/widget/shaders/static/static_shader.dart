import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shaders/static/static_painter.dart';

class StaticShader extends BaseStaticShader {
  const StaticShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    Color? shadowColor,
    double? width,
    double? height,
  }) : super(
          key: key,
          bytes: bytes,
          noImageBuilder: noImageBuilder,
          width: width,
          height: height,
          shadowColor: shadowColor,
          uri: uri,
        );

  @override
  State<StatefulWidget> createState() => _StaticShaderState();
}

class _StaticShaderState extends BaseStaticShaderState<StaticShader> {
  @override
  Widget build(BuildContext context) {
    final srcImage = image;

    if (srcImage == null) return widget.noImageBuilder(context);

    return CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: StaticPainter(
        image: srcImage,
        shadowColor: widget.shadowColor,
      ),
    );
  }
}
