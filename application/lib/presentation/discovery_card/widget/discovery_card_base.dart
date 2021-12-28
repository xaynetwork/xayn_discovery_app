import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

const BoxFit _kImageBoxFit = BoxFit.cover;

/// The base class for the different feed cards.
abstract class DiscoveryCardBase extends StatefulWidget {
  final bool isPrimary;
  final Document document;
  final DiscoveryCardManager? discoveryCardManager;
  final ImageManager? imageManager;
  final BoxFit imageBoxFit;

  const DiscoveryCardBase({
    Key? key,
    required this.isPrimary,
    required this.document,
    this.discoveryCardManager,
    this.imageManager,
    this.imageBoxFit = _kImageBoxFit,
  }) : super(key: key);
}

/// The base class for the different feed card states.
abstract class DiscoveryCardBaseState<T extends DiscoveryCardBase>
    extends State<T> {
  late final DiscoveryCardManager _discoveryCardManager;
  late final ImageManager _imageManager;
  late final DiscoveryCardActionsManager _actionsManager;

  DiscoveryCardManager get discoveryCardManager => _discoveryCardManager;
  ImageManager get imageManager => _imageManager;
  DiscoveryCardActionsManager get actionsManager => _actionsManager;

  WebResource get webResource => widget.document.webResource;
  Uri get url => webResource.url;
  String get imageUrl => webResource.displayUrl.toString();
  String get snippet => webResource.snippet;
  String get title => webResource.title;

  @override
  void initState() {
    super.initState();

    _discoveryCardManager = widget.discoveryCardManager ?? di.get();
    _imageManager = widget.imageManager ?? di.get();
    _actionsManager = di.get();
  }

  @override
  void dispose() {
    super.dispose();

    if (widget.discoveryCardManager == null) {
      _discoveryCardManager.close();
    }

    if (widget.imageManager == null) {
      _imageManager.close();
    }
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPrimary && oldWidget.document != widget.document) {
      _discoveryCardManager.updateUri(url);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
        bloc: _discoveryCardManager,
        builder: (context, state) => buildFromState(
          context,
          state,
          _buildImage(),
        ),
      );

  Widget buildFromState(
    BuildContext context,
    DiscoveryCardState state,
    Widget image,
  );

  Gradient buildGradient({double opacity = 1.0}) => LinearGradient(
        colors: [
          R.colors.swipeCardBackground.withAlpha(120),
          R.colors.swipeCardBackground.withAlpha(40),
          R.colors.swipeCardBackground
              .withAlpha(127 + (128.0 * opacity).floor()),
          R.colors.swipeCardBackground
              .withAlpha(127 + (128.0 * opacity).floor()),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.15, 0.8, 1],
      );

  Widget _buildImage() {
    final mediaQuery = MediaQuery.of(context);
    final backgroundPane = ColoredBox(color: R.colors.swipeCardBackground);

    return CachedImage(
      imageManager: _imageManager,
      uri: Uri.parse(imageUrl),
      width: mediaQuery.size.width.ceil(),
      height: mediaQuery.size.height.ceil(),
      fit: widget.imageBoxFit,
      loadingBuilder: (context, progress) => backgroundPane,
      errorBuilder: (context) => Text('${Strings.cannotLoadUrlError}$imageUrl'),
    );
  }
}
