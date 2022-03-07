import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager_state.dart';

typedef ImageLoadingBuilder = Widget Function(
  BuildContext context,
  double progress,
);
typedef ImageErrorWidgetBuilder = Widget Function(BuildContext context);

class CachedImage extends StatefulWidget {
  final Uri uri;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageErrorWidgetBuilder? noImageBuilder;
  final int? width;
  final int? height;
  final BoxFit? fit;
  final ImageManager? imageManager;

  const CachedImage({
    Key? key,
    required this.uri,
    this.loadingBuilder,
    this.errorBuilder,
    this.noImageBuilder,
    this.width,
    this.height,
    this.fit,
    this.imageManager,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  late final ImageManager _imageManager;

  @override
  void initState() {
    super.initState();

    final imageManager = widget.imageManager;

    if (imageManager == null) {
      _imageManager = di.get()..getImage(widget.uri);
    } else {
      _imageManager = imageManager;
    }
  }

  @override
  void dispose() {
    super.dispose();

    // if the imageManager was created locally, then close it,
    // otherwise let the owner take care of it.
    if (widget.imageManager == null) {
      _imageManager.close();
    }
  }

  @override
  void didUpdateWidget(CachedImage oldWidget) {
    if (oldWidget.uri != widget.uri) {
      _imageManager.getImage(widget.uri);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final loadingBuilder = widget.loadingBuilder ??
        (
          BuildContext context,
          double progress,
        ) =>
            const CircularProgressIndicator();
    final errorBuilder = widget.errorBuilder ??
        (BuildContext context) => kReleaseMode
            ? Container()
            : const Text('asset was not loaded here');

    final noImageBuilder = widget.noImageBuilder ??
        (BuildContext context) => Container(
              color: R.colors.swipeCardBackgroundHome,
            );

    return BlocBuilder<ImageManager, ImageManagerState>(
        bloc: _imageManager,
        builder: (context, state) {
          if (state.uri != widget.uri) {
            final uriAsParam = state.uri?.queryParameters['url'];

            if (uriAsParam != widget.uri.toString()) {
              return loadingBuilder(context, .0);
            }
          }

          if (state.hasError) {
            return errorBuilder(context);
          } else if (state.progress < 1.0) {
            return loadingBuilder(context, state.progress);
          }

          final bytes = state.bytes;

          if (bytes != null) {
            return Image.memory(
              bytes,
              width: widget.width?.toDouble(),
              height: widget.height?.toDouble(),
              fit: widget.fit,
              gaplessPlayback: true,
              errorBuilder: (_, e, s) {
                // try to decode the data as an svg
                final svgFuture =
                    SvgPicture.svgByteDecoderBuilder(const SvgTheme())(
                        bytes, null, '');

                return FutureBuilder<PictureInfo>(
                    future: svgFuture,
                    builder: (_, snapshot) {
                      // if decoding failed, or pending, return the fallback
                      if (snapshot.hasError || !snapshot.hasData) {
                        return noImageBuilder(context);
                      }

                      return SvgPicture.memory(
                        bytes,
                        width: widget.width?.toDouble(),
                        height: widget.height?.toDouble(),
                        fit: widget.fit ?? BoxFit.cover,
                        placeholderBuilder: noImageBuilder,
                      );
                    });
              },
            );
          } else {
            // there is no image
            return noImageBuilder(context);
          }
        });
  }
}
