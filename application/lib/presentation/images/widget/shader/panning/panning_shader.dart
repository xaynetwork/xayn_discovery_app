import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/panning/panning_painter.dart';

const double _kPixelDuration = .065;

class PanningShader extends BaseAnimationShader {
  const PanningShader({
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
  State<StatefulWidget> createState() => _PanningShaderState();
}

class _PanningShaderState extends BaseAnimationShaderState<PanningShader> {
  @override
  Widget build(BuildContext context) {
    final srcImage = image;

    if (srcImage == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.noImageBuilder(context),
      );
    }

    return CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: PanningPainter(
        image: srcImage,
        animationValue: animationValue,
        shadowColor: widget.shadowColor,
      ),
    );
  }

  @override
  void didResolveImage() {
    final srcImage = image;
    final width = widget.width;

    if (srcImage != null && width != null) {
      final overflow = srcImage.width - width;

      if (overflow > .0) {
        updateDuration(Duration(milliseconds: overflow ~/ _kPixelDuration));
      }
    }

    super.didResolveImage();
  }
}
