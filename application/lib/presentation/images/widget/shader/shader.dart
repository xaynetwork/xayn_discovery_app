import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/static/static_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/panning/panning_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/zoom/zoom_shader.dart';

enum ShaderType { static, pan, zoom }

class ShaderFactory {
  ShaderFactory._();

  static BaseStaticShader Function({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    Color? shadowColor,
    double? width,
    double? height,
    bool? singleFrameOnly,
  }) fromType(ShaderType type, {bool transitionToIdle = false}) => ({
        Key? key,
        required Uint8List bytes,
        required Uri uri,
        required ImageErrorWidgetBuilder noImageBuilder,
        Color? shadowColor,
        double? width,
        double? height,
        bool? singleFrameOnly,
      }) {
        switch (type) {
          case ShaderType.static:
            return StaticShader(
              key: key,
              bytes: bytes,
              uri: uri,
              noImageBuilder: noImageBuilder,
              shadowColor: shadowColor,
              width: width,
              height: height,
            );
          case ShaderType.pan:
            return PanningShader(
              key: key,
              bytes: bytes,
              uri: uri,
              noImageBuilder: noImageBuilder,
              shadowColor: shadowColor,
              width: width,
              height: height,
              transitionToIdle: transitionToIdle,
              singleFrameOnly: singleFrameOnly,
            );
          case ShaderType.zoom:
            return ZoomShader(
              key: key,
              bytes: bytes,
              uri: uri,
              curve: Curves.linear,
              noImageBuilder: noImageBuilder,
              shadowColor: shadowColor,
              width: width,
              height: height,
              transitionToIdle: transitionToIdle,
              singleFrameOnly: singleFrameOnly,
            );
        }
      };
}
