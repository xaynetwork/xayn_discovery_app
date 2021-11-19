import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager_state.dart';

class CachedImage extends StatefulWidget {
  final Uri uri;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final int? width;
  final int? height;
  final BoxFit? fit;

  const CachedImage({
    Key? key,
    required this.uri,
    this.loadingBuilder,
    this.errorBuilder,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  late final ImageManager _imageManager;

  @override
  void initState() {
    _imageManager = di.get();
    _imageManager.getImage(
      widget.uri,
      width: widget.width,
      height: widget.height,
    );

    super.initState();
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    if (oldWidget.uri != widget.uri ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height) {
      _imageManager.getImage(
        widget.uri,
        width: widget.width,
        height: widget.height,
      );
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _imageManager.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingBuilder = widget.loadingBuilder ??
        () => const CircularProgressIndicator.adaptive();
    final errorBuilder = widget.errorBuilder ?? () => const Text('oops!');

    return BlocBuilder<ImageManager, ImageManagerState>(
        bloc: _imageManager,
        builder: (context, state) {
          if (state.uri != widget.uri) {
            return loadingBuilder();
          }

          if (state.hasError) {
            return errorBuilder();
          } else if (state.progress < 1.0) {
            return loadingBuilder();
          }

          final bytes = state.bytes;

          if (bytes != null) {
            return Image.memory(
              bytes,
              width: widget.width?.toDouble(),
              height: widget.height?.toDouble(),
              fit: widget.fit,
              gaplessPlayback: true,
            );
          }

          return loadingBuilder();
        });
  }
}
