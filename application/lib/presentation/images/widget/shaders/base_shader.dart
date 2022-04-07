import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';

const double _kFactor = 30;

class _Cache {
  static final _entries = <Uri, ui.Image>{};

  static bool contains(Uri uri) => _entries.containsKey(uri);
  static ui.Image? of(Uri uri) => _entries[uri];

  static void put(Uri uri, ui.Image image) => _entries[uri] = image;
}

abstract class BaseStaticShader extends StatefulWidget {
  final Uint8List bytes;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder noImageBuilder;
  final Color shadowColor;
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

  Future<ui.Image> _decodeBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();

    _Cache.put(widget.uri, frameInfo.image);

    return frameInfo.image;
  }
}

abstract class BaseAnimationShader extends BaseStaticShader {
  final Curve curve;

  const BaseAnimationShader({
    Key? key,
    required Uint8List bytes,
    required Uri uri,
    required ImageErrorWidgetBuilder noImageBuilder,
    required Color shadowColor,
    double? width,
    double? height,
    Curve? curve,
  })  : curve = curve ?? Curves.easeInOut,
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
    final srcImage = image!;
    final dx = (widget.width ?? srcImage.width) - srcImage.width;
    final durationInDirection = 1000 * dx.abs() ~/ _kFactor;

    _controller.duration = _controller.reverseDuration =
        Duration(milliseconds: durationInDirection);

    final curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    final tween = Tween(begin: -1.0, end: 1.0);

    _controller.duration;

    _animation = tween.animate(curve)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.forward();
  }
}
