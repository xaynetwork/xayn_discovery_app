import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/painters/traversing_painter.dart';

class AnimatedImage extends StatefulWidget {
  final Uint8List bytes;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder noImageBuilder;
  final Color shadowColor;
  final Uri uri;

  const AnimatedImage({
    Key? key,
    required this.bytes,
    required this.uri,
    required this.noImageBuilder,
    required this.shadowColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<AnimatedImage>
    with SingleTickerProviderStateMixin {
  static final _cache = <Uri, ui.Image>{};
  late final _controller = AnimationController(vsync: this);
  ui.Image? _image;
  Animation? _animation;

  @override
  void initState() {
    _resolveImage();

    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedImage oldWidget) {
    if (oldWidget.bytes != widget.bytes) {
      _resolveImage();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) return widget.noImageBuilder(context);

    return CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: TraversingPainter(
          image: _image!,
          shadowColor: widget.shadowColor,
          offset: Offset(_animation?.value ?? .0, .0)),
    );
  }

  void _resolveImage() {
    if (_cache.containsKey(widget.uri)) {
      _image = _cache[widget.uri];

      _startAnimation();
    } else {
      _decodeBytes(widget.bytes).then((it) {
        _startAnimation();

        setState(() => _image = it);
      });
    }
  }

  void _startAnimation() {
    final image = _cache[widget.uri]!;
    final dx = (widget.width ?? image.width) - image.width;

    _controller.duration = Duration(seconds: dx.abs() ~/ 10);

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    final tween = Tween(begin: dx, end: .0);

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

    _controller.forward(from: .5);
  }

  Future<ui.Image> _decodeBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();

    _cache[widget.uri] = frameInfo.image;

    return frameInfo.image;
  }
}
