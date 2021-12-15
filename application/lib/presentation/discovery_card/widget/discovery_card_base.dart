import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';

const BoxFit kBoxFit = BoxFit.cover;

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
  late final Size _mediaSize;

  DiscoveryCardManager get discoveryCardManager => _discoveryCardManager;
  ImageManager get imageManager => _imageManager;

  WebResource get webResource => widget.document.webResource;
  Uri get url => webResource.url;
  String get imageUrl => webResource.displayUrl.toString();
  String get snippet => webResource.snippet;
  String get title => webResource.title;

  bool _didFetchImage = false;

  @override
  void initState() {
    super.initState();

    final discoveryCardManager = widget.discoveryCardManager;
    final imageManager = widget.imageManager;

    if (discoveryCardManager == null) {
      _discoveryCardManager = di.get();
    } else {
      _discoveryCardManager = discoveryCardManager;
    }

    if (imageManager == null) {
      _imageManager = di.get();
    } else {
      _imageManager = imageManager;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didFetchImage) {
      _didFetchImage = true;

      final mediaQuery = MediaQuery.of(context);

      _mediaSize = mediaQuery.size;

      if (widget.imageManager == null) {
        _imageManager.getImage(
          Uri.parse(imageUrl),
          width: _mediaSize.width.ceil(),
          height: _mediaSize.height.ceil(),
          fit: kBoxFit,
        );
      }
    }
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
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
      bloc: _discoveryCardManager,
      builder: (context, state) => buildFromState(
        context,
        state,
        _buildImage(),
      ),
    );
  }

  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image);

  Widget _buildImage() {
    final backgroundPane = ColoredBox(color: R.colors.swipeCardBackground);

    return CachedImage(
      imageManager: _imageManager,
      uri: Uri.parse(imageUrl),
      width: _mediaSize.width.ceil(),
      height: _mediaSize.height.ceil(),
      fit: kBoxFit,
      loadingBuilder: (context, progress) => backgroundPane,
      errorBuilder: (context) =>
          Text('Unable to load image with url: $imageUrl'),
    );
  }
}
