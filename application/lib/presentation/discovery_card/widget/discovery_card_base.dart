import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/utils/tooltip_utils.dart';
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
    extends State<T> with TooltipStateMixin {
  late final DiscoveryCardManager _discoveryCardManager;
  late final ImageManager _imageManager;

  DiscoveryCardManager get discoveryCardManager => _discoveryCardManager;

  ImageManager get imageManager => _imageManager;

  WebResource get webResource => widget.document.webResource;

  String get imageUrl => webResource.displayUrl.toString();

  String get snippet => webResource.snippet;

  String get title => webResource.title;

  @override
  void initState() {
    super.initState();

    _discoveryCardManager = widget.discoveryCardManager ?? di.get();
    _imageManager = widget.imageManager ?? di.get();
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
      _discoveryCardManager.updateDocument(widget.document);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DiscoveryCardManager, DiscoveryCardState>(
        bloc: _discoveryCardManager,
        builder: (context, state) => buildFromState(
          context,
          state,
          _buildImage(),
        ),
        listenWhen: (previous, current) =>
            current.hasError || discoveryCardStateListenWhen(previous, current),
        listener: (context, state) {
          if (state.hasError) {
            handleError(state);
          } else {
            discoveryCardStateListener();
          }
        },
      );

  void handleError(DiscoveryCardState state) {
    TooltipKey? key = TooltipUtils.getErrorKey(state.error);
    if (key != null) showTooltip(key);
  }

  bool discoveryCardStateListenWhen(
      DiscoveryCardState prev, DiscoveryCardState curr);

  void discoveryCardStateListener();

  Widget buildFromState(
    BuildContext context,
    DiscoveryCardState state,
    Widget image,
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
      errorBuilder: (context) =>
          Text('${R.strings.cannotLoadUrlError}$imageUrl'),
    );
  }
}
