import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';

class SharedCardImage extends StatefulWidget {
  final Uri uri;
  final ImageManager? imageManager;
  final SharedCardImageController? controller;

  const SharedCardImage({
    Key? key,
    required this.uri,
    this.controller,
    this.imageManager,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SharedCardImageState();
}

class _SharedCardImageState extends State<SharedCardImage> {
  late final SharedCardImageController _controller;
  double effectFraction = .0;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ?? SharedCardImageController(effectFraction);

    effectFraction = _controller.value;

    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    _controller.removeListener(_onControllerUpdate);

    if (widget.controller == null) {
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundPane = ColoredBox(
      color: R.colors.swipeCardBackground,
    );
    final bgColor = R.colors.swipeCardBackground.withOpacity(effectFraction);
    final borderRadius =
        Radius.circular(R.dimen.unit2 * (1.0 - effectFraction));

    return LayoutBuilder(builder: (context, constraints) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: borderRadius,
          bottomRight: borderRadius,
        ),
        child: Container(
          width: constraints.maxWidth,
          height: 2 * constraints.maxHeight / 3,
          decoration: const BoxDecoration(),
          clipBehavior: Clip.antiAlias,
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bgColor,
                bgColor.withAlpha(40),
                bgColor.withAlpha(120),
                bgColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.15, 0.8, 1],
            ),
          ),
          child: CachedImage(
            uri: widget.uri,
            fit: BoxFit.cover,
            imageManager: widget.imageManager,
            loadingBuilder: (context, progress) => backgroundPane,
            errorBuilder: (context) =>
                Text('Unable to load image with uri: ${widget.uri}'),
          ),
        ),
      );
    });
  }

  void _onControllerUpdate() {
    // no way around addPostFrameCallback unfortunately,
    // this is the only way to invoke a setState on an animating Hero
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => effectFraction = _controller.value);
      }
    });
  }
}

class SharedCardImageController extends ValueNotifier<double> {
  SharedCardImageController(value) : super(value);
}
