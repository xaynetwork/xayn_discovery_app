import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/tts/tts_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_elements.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/shader.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class DiscoveryFeedCard extends DiscoveryCardBase {
  DiscoveryFeedCard({
    Key? key,
    required bool isPrimary,
    required Document document,
    FeedType? feedType,
    OnTtsData? onTtsData,
    ShaderBuilder? primaryCardShader,
  }) : super(
          key: key,
          isPrimary: isPrimary,
          document: document,
          onTtsData: onTtsData,
          feedType: feedType,
          primaryCardShader:
              primaryCardShader ?? ShaderFactory.fromType(ShaderType.static),
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedCardState();
}

class _DiscoveryFeedCardState extends DiscoveryCardBaseState<DiscoveryFeedCard>
    with OverlayMixin<DiscoveryFeedCard> {
  @override
  OverlayManager get overlayManager => discoveryCardManager.overlayManager;

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final timeToReadOrError = state.processedDocument?.timeToRead ?? '';
    final processedDocument = state.processedDocument;
    final provider = processedDocument?.getProvider(webResource);

    final elements = DiscoveryCardElements(
      manager: discoveryCardManager,
      document: widget.document,
      explicitDocumentUserReaction: state.explicitDocumentUserReaction,
      title: webResource.title,
      timeToRead: timeToReadOrError,
      url: webResource.url,
      provider: provider,
      datePublished: webResource.datePublished,
      isInteractionEnabled: widget.isPrimary,
      onLikePressed: () => onFeedbackPressed(UserReaction.positive),
      onDislikePressed: () => onFeedbackPressed(UserReaction.negative),
      onOpenUrl: () {
        widget.onTtsData?.call(TtsData.disabled());

        discoveryCardManager.openWebResourceUrl(
          widget.document,
          CurrentView.story,
          widget.feedType,
        );
      },
      onToggleTts: () => widget.onTtsData?.call(
        TtsData(
          enabled: true,
          languageCode: widget.document.resource.language,
          uri: widget.document.resource.url,
          html: discoveryCardManager
              .state.processedDocument?.processHtmlResult.contents,
        ),
      ),
      onBookmarkPressed: () => onBookmarkPressed(feedType: widget.feedType),
      onBookmarkLongPressed: onBookmarkLongPressed(state),
      bookmarkStatus: state.bookmarkStatus,
      feedType: widget.feedType,
    );

    return Stack(
      children: [
        image,
        elements,
      ],
    );
  }

  @override
  Widget buildImage(Color shadowColor) =>
      super.buildImage(R.colors.swipeCardBackgroundHome);
}
