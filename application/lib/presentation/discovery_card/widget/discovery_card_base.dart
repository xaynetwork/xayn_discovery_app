import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';

const BoxFit _kBoxFit = BoxFit.cover;

abstract class DiscoveryCardBase extends StatefulWidget {
  final bool isPrimary;
  final Document document;
  final DiscoveryCardManager? discoveryCardManager;
  final ImageManager? imageManager;

  const DiscoveryCardBase({
    Key? key,
    required this.isPrimary,
    required this.document,
    this.discoveryCardManager,
    this.imageManager,
  }) : super(key: key);
}

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

  late bool _didFetchImage;

  @override
  void initState() {
    super.initState();

    final discoveryCardManager = widget.discoveryCardManager;
    final imageManager = widget.imageManager;

    _didFetchImage = widget.imageManager != null;

    if (discoveryCardManager == null) {
      _discoveryCardManager = di.get()..updateUri(url);
    } else {
      _discoveryCardManager = discoveryCardManager;
    }

    if (imageManager == null) {
      _imageManager = di.get();
    } else {
      _imageManager = imageManager;
    }

    _actionsManager = di.get();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didFetchImage) return;

    _didFetchImage = true;

    final mediaQuery = MediaQuery.of(context);

    _imageManager.getImage(
      Uri.parse(imageUrl),
      width: mediaQuery.size.width.ceil(),
      height: mediaQuery.size.height.ceil(),
      fit: _kBoxFit,
    );
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
          R.colors.swipeCardBackground.withAlpha((120.0 * opacity).floor()),
          R.colors.swipeCardBackground.withAlpha((40.0 * opacity).floor()),
          R.colors.swipeCardBackground.withAlpha((255.0 * opacity).floor()),
          R.colors.swipeCardBackground.withAlpha((255.0 * opacity).floor()),
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
      fit: _kBoxFit,
      loadingBuilder: (context, progress) => backgroundPane,
      errorBuilder: (context) => Text('${Strings.cannotLoadUrlError}$imageUrl'),
    );
  }
}
