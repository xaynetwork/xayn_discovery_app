import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/static/static_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/panning/panning_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/zoom/zoom_shader.dart';

/// A list of all possible shaders which can be targeted in the UI.
enum ShaderType { static, pan, zoom }

/// A factory which creates [ShaderBuilder]s.
class ShaderFactory {
  ShaderFactory._();

  /// For a given [ShaderType], returns a [ShaderBuilder] method.
  /// When [transitionToIdle] is true, the shader will animate the current
  /// animation status to static. If false, it will play in a continuous loop instead.
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
