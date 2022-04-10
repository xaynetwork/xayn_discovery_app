import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/zoom/zoom_painter.dart';

class ZoomShader extends BaseAnimationShader {
  const ZoomShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    Color? shadowColor,
    bool? transitionToIdle,
    Curve? curve,
    double? width,
    double? height,
    bool? singleFrameOnly,
  }) : super(
          key: key,
          bytes: bytes,
          noImageBuilder: noImageBuilder,
          curve: curve,
          width: width,
          height: height,
          shadowColor: shadowColor,
          uri: uri,
          transitionToIdle: transitionToIdle ?? false,
          singleFrameOnly: singleFrameOnly ?? false,
        );

  @override
  State<StatefulWidget> createState() => _ZoomShaderState();
}

class _ZoomShaderState extends BaseAnimationShaderState<ZoomShader> {
  @override
  Widget build(BuildContext context) {
    final srcImage = image;

    if (srcImage == null) return widget.noImageBuilder(context);

    return CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: ZoomPainter(
        image: srcImage,
        animationValue: animationValue,
        shadowColor: widget.shadowColor,
      ),
    );
  }
}
