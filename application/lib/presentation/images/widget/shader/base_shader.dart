import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader_cache.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

enum ShaderAnimationDirection { forward, reverse }

abstract class BaseStaticShader extends StatefulWidget {
  final Uint8List bytes;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder noImageBuilder;
  final Color? shadowColor;
  final Uri uri;

  const BaseStaticShader({
    Key? key,
    required this.bytes,
    required this.noImageBuilder,
    required this.shadowColor,
    required this.uri,
    this.width,
    this.height,
  }) : super(key: key);
}

abstract class BaseStaticShaderState<T extends BaseStaticShader>
    extends State<T> {
  late final ShaderCache _cache = di.get();
  ShaderAnimationDirection _currentDirection = ShaderAnimationDirection.forward;
  ui.Image? _image;

  ui.Image? get image => _image ?? _cache.of(widget.uri);

  @override
  void initState() {
    _cache.refCountFor(widget.uri);

    _resolveImage();

    super.initState();
  }

  @override
  void dispose() {
    _cache.flush(widget.uri);

    super.dispose();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if (oldWidget.bytes != widget.bytes) {
      _resolveImage();
    }

    super.didUpdateWidget(oldWidget);
  }

  void didResolveImage() {}

  void _resolveImage() {
    if (_cache.contains(widget.uri)) {
      didResolveImage();
    } else {
      _decodeBytes(widget.bytes).whenComplete(() => setState(didResolveImage));
    }
  }

  Future<ui.Image?> _decodeBytes(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();

      _cache.put(widget.uri, frameInfo.image);

      return frameInfo.image;
    } catch (e) {
      logger.i('Unable to decode image at: ${widget.uri}');
    }

    return null;
  }
}

abstract class BaseAnimationShader extends BaseStaticShader {
  final Curve curve;
  final bool transitionToIdle;
  final bool looping;
  final Duration duration;

  const BaseAnimationShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    this.transitionToIdle = false,
    this.looping = true,
    Color? shadowColor,
    Duration? duration,
    Curve? curve = Curves.easeInOut,
    double? width,
    double? height,
  })  : curve = curve ?? Curves.easeInOut,
        duration = duration ?? const Duration(seconds: 15),
        super(
          key: key,
          uri: uri,
          shadowColor: shadowColor,
          noImageBuilder: noImageBuilder,
          bytes: bytes,
          width: width,
          height: height,
        );
}

abstract class BaseAnimationShaderState<T extends BaseAnimationShader>
    extends BaseStaticShaderState<T> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    animationBehavior: AnimationBehavior.preserve,
    duration: widget.duration,
  );

  Animation? _animation;

  Animation? get animation => _animation;
  double get animationValue => _animation?.value ?? .0;

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  void didResolveImage() {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    final tween = Tween(begin: .0, end: 1.0);
    final status = _cache.latestAnimationStatus(widget.uri);

    updateAnimationValue() => _cache.updateAnimationValue(
        widget.uri,
        ShaderAnimationStatus(
          position: animationValue,
          direction: _currentDirection,
        ));

    _animation = tween.animate(curve)
      ..addListener(() => setState(updateAnimationValue))
      ..addStatusListener((status) {
        if (widget.transitionToIdle || !widget.looping) return;

        if (status == AnimationStatus.completed) {
          _currentDirection = ShaderAnimationDirection.reverse;
          _controller.reverse();
          updateAnimationValue();
        } else if (status == AnimationStatus.dismissed) {
          _currentDirection = ShaderAnimationDirection.forward;
          _controller.forward();
          updateAnimationValue();
        }
      });

    if (widget.transitionToIdle) {
      _controller.value = status.position;
      _controller.animateTo(
        .5,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOutExpo,
      );
    } else {
      switch (status.direction) {
        case ShaderAnimationDirection.forward:
          _currentDirection = ShaderAnimationDirection.forward;
          _controller.forward(from: status.position);
          break;
        case ShaderAnimationDirection.reverse:
          _currentDirection = ShaderAnimationDirection.reverse;
          _controller.reverse(from: status.position);
          break;
      }
    }
  }
}
