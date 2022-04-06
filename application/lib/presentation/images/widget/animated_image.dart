import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' hide ImageErrorWidgetBuilder;
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/painters/static_painter.dart';

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
  ui.Image? _image;

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
  Widget build(BuildContext context) {
    if (_image == null) return widget.noImageBuilder(context);

    return CustomPaint(
      size: Size(widget.width ?? .0, widget.height ?? .0),
      painter: StaticPainter(
        image: _image!,
        shadowColor: widget.shadowColor,
      ),
    );
  }

  void _resolveImage() {
    if (_cache.containsKey(widget.uri)) {
      _image = _cache[widget.uri];
    } else {
      _decodeBytes(widget.bytes).then((it) => setState(() => _image = it));
    }
  }

  Future<ui.Image> _decodeBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();

    _cache[widget.uri] = frameInfo.image;

    return frameInfo.image;
  }
}
