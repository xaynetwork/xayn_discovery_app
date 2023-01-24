import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager_state.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/base_shader.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_app/presentation/widget/widget_testable_progress_indicator.dart';

typedef ImageLoadingBuilder = Widget Function(
  BuildContext context,
  double progress,
);
typedef ImageErrorWidgetBuilder = Widget Function(BuildContext context);
typedef ShaderBuilder = BaseStaticShader Function({
  Key? key,
  required Uint8List bytes,
  required Uri uri,
  required ImageErrorWidgetBuilder noImageBuilder,
  double? width,
  double? height,
  bool? singleFrameOnly,
});

class CachedImage extends StatefulWidget {
  final Uri uri;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageErrorWidgetBuilder? noImageBuilder;
  final int? width;
  final int? height;
  final ImageManager? imageManager;
  final ShaderBuilder shaderBuilder;
  final bool? singleFrameOnly;
  final String? semanticsLabel;

  CachedImage({
    Key? key,
    required this.uri,
    this.loadingBuilder,
    this.errorBuilder,
    this.noImageBuilder,
    this.width,
    this.height,
    this.imageManager,
    this.singleFrameOnly,
    this.semanticsLabel,
    ShaderBuilder? shaderBuilder,
  })  : shaderBuilder =
            shaderBuilder ?? ShaderFactory.fromType(ShaderType.static),
        super(key: key);

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
        (BuildContext context, double progress) =>
            const WidgetTestableProgressIndicator();
    final errorBuilder = widget.errorBuilder ??
        (BuildContext context) => kReleaseMode
            ? Container()
            : const Text('asset was not loaded here');

    final noImageBuilder = widget.noImageBuilder ??
        (BuildContext context) =>
            Container(color: R.colors.swipeCardBackgroundHome);

    return BlocBuilder<ImageManager, ImageManagerState>(
      bloc: _imageManager,
      builder: (context, state) {
        var opacity = .0;

        buildChild() {
          if (state.uri != widget.uri) {
            final uriAsParam = state.uri?.queryParameters['url'];

            if (uriAsParam != widget.uri.toString()) {
              return loadingBuilder(context, .0);
            }
          }

          if (state.hasError) {
            return errorBuilder(context);
          } else if (state.progress < 1.0) {
            /// We need to set the opacity to 1.0 otherwise
            /// the loading widget would not be visible
            opacity = 1.0;
            return loadingBuilder(context, state.progress);
          }

          final bytes = state.bytes;

          if (bytes != null) {
            opacity = 1.0;

            return widget.shaderBuilder(
              key: Key(widget.uri.toString()),
              uri: widget.uri,
              width: widget.width?.toDouble(),
              height: widget.height?.toDouble(),
              bytes: bytes,
              noImageBuilder: noImageBuilder,
              singleFrameOnly: widget.singleFrameOnly,
            );
          } else {
            // there is no image
            return noImageBuilder(context);
          }
        }

        final child = widget.semanticsLabel != null
            ? Semantics(
                image: true,
                child: buildChild(),
              )
            : buildChild();

        return AnimatedOpacity(
          opacity: opacity,
          duration: R.animations.unit2,
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
