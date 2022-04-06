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

  const AnimatedImage({
    Key? key,
    required this.bytes,
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
  late Future<ui.Image> _image;

  @override
  void initState() {
    _image = _decodeBytes(widget.bytes);

    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedImage oldWidget) {
    if (oldWidget.bytes != widget.bytes) {
      _image = _decodeBytes(widget.bytes);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => _buildImage();

  Widget _buildImage() => FutureBuilder<ui.Image>(
        future: _image,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return widget.noImageBuilder(context);

          return CustomPaint(
            size: Size(widget.width ?? .0, widget.height ?? .0),
            painter: StaticPainter(
              image: snapshot.requireData,
              shadowColor: widget.shadowColor,
            ),
          );
        },
      );

  Future<ui.Image> _decodeBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();

    return frameInfo.image;
  }
}
