import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/static/static_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/traversal/traversal_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/zoom/zoom_shader.dart';

enum ShaderType { static, traverse, zoom }

class ShaderFactory {
  ShaderFactory._();

  static BaseStaticShader Function({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    Color? shadowColor,
    Curve? curve,
    double? width,
    double? height,
  }) fromType(ShaderType type, {bool transitionToIdle = false}) => ({
        Key? key,
        required Uint8List bytes,
        required Uri uri,
        required ImageErrorWidgetBuilder noImageBuilder,
        Color? shadowColor,
        Curve? curve,
        double? width,
        double? height,
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
          case ShaderType.traverse:
            return TraversalShader(
              key: key,
              bytes: bytes,
              uri: uri,
              noImageBuilder: noImageBuilder,
              shadowColor: shadowColor,
              width: width,
              height: height,
              transitionToIdle: transitionToIdle,
            );
          case ShaderType.zoom:
            return ZoomShader(
              key: key,
              bytes: bytes,
              uri: uri,
              noImageBuilder: noImageBuilder,
              shadowColor: shadowColor,
              width: width,
              height: height,
              transitionToIdle: transitionToIdle,
            );
        }
      };
}
