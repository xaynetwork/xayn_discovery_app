import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

enum ShaderAnimationDirection { forward, reverse }

class _Cache {
  static final _entries = <Uri, ui.Image>{};
  static final _animationStatus = <Uri, ShaderAnimationStatus>{};

  static bool contains(Uri uri) => _entries.containsKey(uri);
  static ui.Image? of(Uri uri) => _entries[uri];

  static void put(Uri uri, ui.Image image) => _entries[uri] = image;

  static ShaderAnimationStatus latestAnimationStatus(Uri uri) =>
      _animationStatus[uri] ?? const ShaderAnimationStatus.start();
  static void updateAnimationValue(Uri uri, ShaderAnimationStatus value) =>
      _animationStatus[uri] = value;
}

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
  ShaderAnimationDirection _currentDirection = ShaderAnimationDirection.forward;
  ui.Image? _image;

  ui.Image? get image => _image ?? _Cache.of(widget.uri);

  @override
  void initState() {
    _resolveImage();

    super.initState();
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
    if (_Cache.contains(widget.uri)) {
      didResolveImage();
    } else {
      _decodeBytes(widget.bytes).whenComplete(didResolveImage);
    }
  }

  Future<ui.Image?> _decodeBytes(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();

      _Cache.put(widget.uri, frameInfo.image);

      return frameInfo.image;
    } catch (e) {
      logger.i('Unable to decode image at: ${widget.uri}');
    }

    return null;
  }
}

abstract class BaseAnimationShader extends BaseStaticShader {
  final Curve curve;
  final bool rendersOnlyOnce;
  final Duration duration;

  const BaseAnimationShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    this.rendersOnlyOnce = false,
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
    final status = _Cache.latestAnimationStatus(widget.uri);

    updateAnimationValue() => _Cache.updateAnimationValue(
        widget.uri,
        ShaderAnimationStatus(
          position: animationValue,
          direction: _currentDirection,
        ));

    _animation = tween.animate(curve)
      ..addListener(() => setState(updateAnimationValue))
      ..addStatusListener((status) {
        if (widget.rendersOnlyOnce) return;

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

    if (widget.rendersOnlyOnce) {
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

class ShaderAnimationStatus {
  final double position;
  final ShaderAnimationDirection direction;

  const ShaderAnimationStatus({
    required this.position,
    required this.direction,
  });

  const ShaderAnimationStatus.start()
      : position = .5,
        direction = ShaderAnimationDirection.forward;
}
