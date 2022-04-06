import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

typedef OnTtsData = void Function(TtsData);

/// The base class for the different feed cards.
abstract class DiscoveryCardBase extends StatefulWidget {
  final bool isPrimary;
  final Document document;
  final FeedType? feedType;
  final DiscoveryCardManager? discoveryCardManager;
  final ImageManager? imageManager;
  final OnTtsData? onTtsData;

  const DiscoveryCardBase({
    Key? key,
    required this.isPrimary,
    required this.document,
    required this.feedType,
    this.discoveryCardManager,
    this.imageManager,
    this.onTtsData,
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
            handleError(state.error, showTooltip);
          }
        },
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
          onError: (tooltipKey) => showTooltip(tooltipKey),
          feedType: widget.feedType,
        ),
      );
    };
  }

  Widget _buildImage() {
    final mediaQuery = MediaQuery.of(context);

    // allow opaque-when-loading, because the card will fade in on load completion.
    buildBackgroundPane({required bool opaque}) =>
        Container(color: opaque ? null : R.colors.swipeCardBackgroundHome);

    return CachedImage(
      imageManager: imageManager,
      uri: Uri.parse(imageUrl),
      width: mediaQuery.size.width.ceil(),
      height: mediaQuery.size.height.ceil(),
      loadingBuilder: (_, __) => buildBackgroundPane(opaque: true),
      errorBuilder: (_) => buildBackgroundPane(opaque: false),
      noImageBuilder: (_) => buildBackgroundPane(opaque: false),
    );
  }
}
