import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_mixin.dart';
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
    extends State<T> with TooltipStateMixin, ErrorHandlingMixin {
  late final DiscoveryCardManager discoveryCardManager;
  late final ImageManager imageManager;

  NewsResource get webResource => widget.document.resource;

  String get imageUrl => webResource.image.toString();

  String get snippet => webResource.snippet;

  String get title => webResource.title;

  @override
  void initState() {
    super.initState();

    discoveryCardManager = widget.discoveryCardManager ?? di.get()
      ..updateDocument(widget.document);
    imageManager = widget.imageManager ?? di.get()
      ..getImage(widget.document.resource.image);
  }

  @override
  void dispose() {
    super.dispose();

    if (widget.discoveryCardManager == null) {
      discoveryCardManager.close();
    }

    if (widget.imageManager == null) {
      imageManager.close();
    }
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPrimary && oldWidget.document != widget.document) {
      discoveryCardManager.updateDocument(widget.document);
      imageManager.getImage(widget.document.resource.image);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<DiscoveryCardManager, DiscoveryCardState>(
        bloc: discoveryCardManager,
        builder: (context, state) => buildFromState(
          context,
          state,
          _buildImage(),
        ),
        listener: (context, state) {
          if (state.error.hasError) {
            handleError(context, state.error, showTooltip);
          } else {
            discoveryCardStateListener(state);
          }
        },
      );

  void discoveryCardStateListener(DiscoveryCardState state);

  Widget buildFromState(
    BuildContext context,
    DiscoveryCardState state,
    Widget image,
  );

  void onBookmarkPressed() =>
      discoveryCardManager.toggleBookmarkDocument(widget.document);

  void Function() onBookmarkLongPressed(DiscoveryCardState state) =>
      () => showAppBottomSheet(
            context,
            builder: (_) => MoveDocumentToCollectionBottomSheet(
              document: widget.document,
              provider: state.processedDocument
                  ?.getProvider(widget.document.resource),
              onError: (tooltipKey) => showTooltip(tooltipKey),
            ),
          );

  Widget _buildImage() {
    final mediaQuery = MediaQuery.of(context);
    final backgroundPane = ColoredBox(color: R.colors.swipeCardBackground);

    return CachedImage(
      imageManager: imageManager,
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
