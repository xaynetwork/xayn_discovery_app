import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class DiscoveryFeedCard extends DiscoveryCardBase {
  const DiscoveryFeedCard({
    Key? key,
    required bool isPrimary,
    required Document document,
    DiscoveryCardManager? discoveryCardManager,
    ImageManager? imageManager,
  }) : super(
          key: key,
          isPrimary: isPrimary,
          document: document,
          discoveryCardManager: discoveryCardManager,
          imageManager: imageManager,
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedCardState();
}

class _DiscoveryFeedCardState
    extends DiscoveryCardBaseState<DiscoveryFeedCard> {
  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final timeToRead = state.processedDocument?.timeToRead ?? '';
    final processedDocument = state.processedDocument;
    final provider = processedDocument?.getProvider(webResource);

    final elements = DiscoveryCardElements(
      manager: discoveryCardManager,
      document: widget.document,
      title: webResource.title,
      timeToRead: timeToRead,
      url: webResource.url,
      provider: provider,
      datePublished: webResource.datePublished,
      onLikePressed: () => discoveryCardManager.changeDocumentFeedback(
        document: widget.document,
        feedback: widget.document.isRelevant
            ? DocumentFeedback.neutral
            : DocumentFeedback.positive,
      ),
      onDislikePressed: () => discoveryCardManager.changeDocumentFeedback(
        document: widget.document,
        feedback: widget.document.isIrrelevant
            ? DocumentFeedback.neutral
            : DocumentFeedback.negative,
      ),
      onOpenUrl: () => discoveryCardManager
          .openUrl(widget.document.webResource.url.toString()),
      onBookmarkPressed: onBookmarkPressed,
      onBookmarkLongPressed: onBookmarkLongPressed(state),
      isBookmarked: state.isBookmarked,
    );

    return Stack(
      children: [
        Container(
            foregroundDecoration: BoxDecoration(
              gradient: buildGradient(),
            ),
            child: image),
        elements
      ],
    );
  }

  @override
  void discoveryCardStateListener() => showTooltip(
        BookmarkToolTipKeys.bookmarkedToDefault,
        parameters: [
          context,
          widget.document,
          discoveryCardManager.state.processedDocument
              ?.getProvider(widget.document.webResource),
          (tooltipKey) => showTooltip(tooltipKey),
        ],
      );

  @override
  bool discoveryCardStateListenWhen(
          DiscoveryCardState previous, DiscoveryCardState current) =>
      !previous.isBookmarked &&
      current.isBookmarked &&
      current.isBookmarkToggled;
}
