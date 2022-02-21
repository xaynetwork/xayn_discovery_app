import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_card_headline_image.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/on_bookmark_changed_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
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

class _DiscoveryFeedCardState extends DiscoveryCardBaseState<DiscoveryFeedCard>
    with OnBookmarkChangedMixin<DiscoveryFeedCard> {
  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final timeToRead = state.processedDocument?.timeToRead ?? '';
    final processedDocument = state.processedDocument;
    final provider = processedDocument?.getProvider(webResource);

    final elements = DiscoveryCardElements(
      manager: discoveryCardManager,
      document: widget.document,
      explicitDocumentUserReaction: state.explicitDocumentUserReaction,
      title: webResource.title,
      timeToRead: timeToRead,
      url: webResource.url,
      provider: provider,
      datePublished: webResource.datePublished,
      onLikePressed: () => discoveryCardManager.onFeedback(
        document: widget.document,
        userReaction: state.explicitDocumentUserReaction.isRelevant
            ? UserReaction.neutral
            : UserReaction.positive,
      ),
      onDislikePressed: () => discoveryCardManager.onFeedback(
        document: widget.document,
        userReaction: state.explicitDocumentUserReaction.isIrrelevant
            ? UserReaction.neutral
            : UserReaction.negative,
      ),
      onOpenUrl: () => discoveryCardManager.openWebResourceUrl(widget.document),
      onBookmarkPressed: onBookmarkPressed,
      onBookmarkLongPressed: onBookmarkLongPressed(state),
      isBookmarked: state.isBookmarked,
    );

    return Stack(
      children: [
        DiscoveryCardHeadlineImage(child: image),
        elements,
      ],
    );
  }

  @override
  void discoveryCardStateListener(DiscoveryCardState state) =>
      onBookmarkChanged(state);
}
