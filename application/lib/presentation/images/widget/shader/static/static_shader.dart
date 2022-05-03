import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/static/static_painter.dart';

class StaticShader extends BaseStaticShader {
  final bool _noImageBuilderIsShadowless;

  const StaticShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    Color? shadowColor,
    double? width,
    double? height,
    bool noImageBuilderIsShadowless = false,
  })  : _noImageBuilderIsShadowless = noImageBuilderIsShadowless,
        super(
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
    final paint = CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: StaticPainter(
        image: srcImage,
        shadowColor: widget.shadowColor,
      ),
    );

    if (srcImage == null) {
      return Stack(
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: widget.noImageBuilder(context),
          ),
          if (!widget._noImageBuilderIsShadowless) paint,
        ],
      );
    }

    return paint;
  }
}
