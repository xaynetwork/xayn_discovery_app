import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/static/static_painter.dart';

class StaticShader extends BaseStaticShader {
  const StaticShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    double? width,
    double? height,
    bool noImageBuilderIsShadowless = false,
    bool? shouldCheckDimen,
  }) : super(
          key: key,
          bytes: bytes,
          noImageBuilder: noImageBuilder,
          width: width,
          height: height,
          uri: uri,
        );

  @override
  State<StatefulWidget> createState() => _StaticShaderState();
}

class _StaticShaderState extends BaseStaticShaderState<StaticShader> {
  @override
  Widget build(BuildContext context) {
    final srcImage = image;

    if (!hasDecodedImage) return Container();

    final paint = CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: StaticPainter(
        image: srcImage,
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
          paint,
        ],
      );
    }

    return paint;
  }
}
