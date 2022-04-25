import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader_cache.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

const Duration _kDefaultDuration = Duration(seconds: 20);

enum ShaderAnimationDirection { forward, reverse }

/// A shader which is static, i.e. does not transition using an animation.
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

/// The state of [BasicStaticShader].
abstract class BaseStaticShaderState<T extends BaseStaticShader>
    extends State<T> {
  late final ShaderCache _cache = di.get();
  ShaderAnimationDirection _currentDirection = ShaderAnimationDirection.forward;

  ui.Image? get image => _cache.imageOf(widget.uri);

  @override
  void initState() {
    _cache.register(widget.uri);

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
    if (_cache.hasImageOf(widget.uri)) {
      didResolveImage();
    } else {
      _decodeBytes(widget.bytes).whenComplete(() => setState(didResolveImage));
    }
  }

  Future<ui.Image?> _decodeBytes(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();

      _cache.update(widget.uri, image: frameInfo.image);

      return frameInfo.image;
    } catch (e) {
      logger.i('Unable to decode image at: ${widget.uri}');
    }

    return null;
  }
}

/// A shader which runs upon an underlying animation.
abstract class BaseAnimationShader extends BaseStaticShader {
  final Curve curve;
  final bool transitionToIdle;
  final bool looping;
  final bool singleFrameOnly;
  final Duration duration;

  const BaseAnimationShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    this.transitionToIdle = false,
    this.looping = true,
    this.singleFrameOnly = false,
    Color? shadowColor,
    Duration? duration,
    Curve? curve = Curves.easeInOut,
    double? width,
    double? height,
  })  : curve = curve ?? Curves.easeInOut,
        duration = duration ?? _kDefaultDuration,
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

/// The state of [BaseAnimationShader].
abstract class BaseAnimationShaderState<T extends BaseAnimationShader>
    extends BaseStaticShaderState<T> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Animation? _animation;

  Animation? get animation => _animation;
  double get animationValue => _animation?.value ?? .0;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
      duration: widget.duration,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    if (oldWidget.singleFrameOnly != widget.singleFrameOnly &&
        oldWidget.uri == widget.uri) {
      final status = _cache.animationStatusOf(widget.uri);

      widget.singleFrameOnly
          ? _stopAnimation(status)
          : _resumeAnimation(status);
    }

    super.didUpdateWidget(oldWidget);
  }

  @mustCallSuper
  @override
  void didResolveImage() {
    final status = _cache.animationStatusOf(widget.uri);
    final curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    final tween = Tween(begin: .0, end: 1.0);

    updateAnimationValue() {
      if (!widget.singleFrameOnly) {
        _cache.update(widget.uri,
            animationStatus: ShaderAnimationStatus(
              position: _controller.value,
              direction: _currentDirection,
            ));
      }
    }

    _animation = tween.animate(curve)
      ..addListener(() => setState(updateAnimationValue))
      ..addStatusListener((status) {
        if (widget.transitionToIdle || !widget.looping) return;

        if (status == AnimationStatus.completed) {
          _currentDirection = ShaderAnimationDirection.reverse;
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _currentDirection = ShaderAnimationDirection.forward;
          _controller.forward();
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
      widget.singleFrameOnly
          ? _stopAnimation(status)
          : _resumeAnimation(status);
    }
  }

  @mustCallSuper
  void updateDuration(Duration duration) => _controller.duration = duration;

  void stop() {
    final status = _cache.animationStatusOf(widget.uri);

    _stopAnimation(status);
  }

  void _stopAnimation(ShaderAnimationStatus status) {
    _controller.value = status.position;
    _controller.stop(canceled: false);
  }

  void _resumeAnimation(ShaderAnimationStatus status) {
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
