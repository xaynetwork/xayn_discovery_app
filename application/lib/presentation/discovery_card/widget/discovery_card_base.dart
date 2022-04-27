import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

typedef OnTtsData = void Function(TtsData);

/// The base class for the different feed cards.
abstract class DiscoveryCardBase extends StatefulWidget {
  final bool isPrimary;
  final Document document;
  final FeedType? feedType;
  final OnTtsData? onTtsData;
  final ShaderBuilder primaryCardShader;

  DiscoveryCardBase({
    Key? key,
    required this.isPrimary,
    required this.document,
    required this.feedType,
    this.onTtsData,
    ShaderBuilder? primaryCardShader,
  })  : primaryCardShader =
            primaryCardShader ?? ShaderFactory.fromType(ShaderType.static),
        super(key: key);
}

/// The base class for the different feed card states.
abstract class DiscoveryCardBaseState<T extends DiscoveryCardBase>
    extends State<T> with OverlayMixin<T> {
  late final CardManagersCache cardManagersCache = di.get();
  late DiscoveryCardManager discoveryCardManager;
  late ImageManager imageManager;

  NewsResource get webResource => widget.document.resource;

  String get imageUrl => webResource.image.toString();

  String get snippet => webResource.snippet;

  String get title => webResource.title;

  @override
  OverlayManager get overlayManager => discoveryCardManager.overlayManager;

  @override
  void initState() {
    updateManagers();
    super.initState();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPrimary && oldWidget.document != widget.document) {
      if (oldWidget.document.resource.url != widget.document.resource.url) {
        updateManagers();
      } else {
        discoveryCardManager.updateDocument(widget.document);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
        bloc: discoveryCardManager,
        builder: (context, state) => buildFromState(
          context,
          state,
          buildImage(R.colors.swipeCardBackgroundDefault),
        ),
      );

  Widget buildFromState(
    BuildContext context,
    DiscoveryCardState state,
    Widget image,
  );

  void onFeedbackPressed(UserReaction requestedReaction) =>
      discoveryCardManager.onFeedback(
        document: widget.document,
        userReaction: discoveryCardManager.state.explicitDocumentUserReaction ==
                requestedReaction
            ? UserReaction.neutral
            : requestedReaction,
        feedType: widget.feedType,
      );

  void onBookmarkPressed({FeedType? feedType}) =>
      discoveryCardManager.toggleBookmarkDocument(
        widget.document,
        feedType: feedType,
      );

  void Function() onBookmarkLongPressed(DiscoveryCardState state) {
    return () {
      discoveryCardManager.triggerHapticFeedbackMedium();
      showAppBottomSheet(
        context,
        builder: (_) => MoveDocumentToCollectionBottomSheet(
          document: widget.document,
          provider:
              state.processedDocument?.getProvider(widget.document.resource),
          feedType: widget.feedType,
        ),
      );
    };
  }

  Widget buildImage(Color shadowColor) {
    final mediaQuery = MediaQuery.of(context);

    // allow opaque-when-loading, because the card will fade in on load completion.
    buildBackgroundPane({required bool opaque}) =>
        Container(color: opaque ? null : R.colors.swipeCardBackgroundHome);

    return CachedImage(
      imageManager: imageManager,
      shaderBuilder: widget.primaryCardShader,
      singleFrameOnly: !widget.isPrimary,
      uri: Uri.parse(imageUrl),
      width: mediaQuery.size.width.floor(),
      height: mediaQuery.size.height.floor(),
      shadowColor: shadowColor,
      loadingBuilder: (_, __) => buildBackgroundPane(opaque: true),
      errorBuilder: (_) => buildBackgroundPane(opaque: false),
      noImageBuilder: (_) => buildBackgroundPane(opaque: false),
    );
  }

  void updateManagers() {
    final managers = cardManagersCache.managersOf(widget.document);

    discoveryCardManager = managers.discoveryCardManager
      ..updateDocument(widget.document);
    imageManager = managers.imageManager
      ..getImage(widget.document.resource.image);
  }
}
