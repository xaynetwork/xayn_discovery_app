import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/utils/semantics_extension.dart';

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.onSharePressed,
    required this.onLikePressed,
    required this.onDislikePressed,
    required this.onDeepSearchPressed,
    required this.document,
    required this.feedType,
    required this.explicitDocumentUserReaction,
  }) : super(key: key);

  final VoidCallback onSharePressed;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;
  final VoidCallback onDeepSearchPressed;
  final Document document;
  final FeedType? feedType;
  final UserReaction explicitDocumentUserReaction;

  @override
  Widget build(BuildContext context) {
    final likeButton = AppGhostButton.icon(
      explicitDocumentUserReaction.isRelevant
          ? R.assets.icons.thumbsUpActive
          : R.assets.icons.thumbsUp,
      onPressed: onLikePressed,
      iconColor: R.colors.brightIcon,
    ).withSemanticsLabel(
      '${Keys.navBarItemLike.valueKey} = ${explicitDocumentUserReaction.isRelevant}',
    );

    final deepSearchButton = AppGhostButton.icon(
      R.assets.icons.binoculars,
      onPressed: onDeepSearchPressed,
      iconColor: R.colors.brightIcon,
    ).withSemanticsLabel(
      '${Keys.navBarItemBookmark.valueKey} = ${explicitDocumentUserReaction.isRelevant}',
    );

    final shareButton = AppGhostButton.icon(
      R.assets.icons.share,
      onPressed: onSharePressed,
      iconColor: R.colors.brightIcon,
    ).withSemanticsLabel(Keys.navBarItemShare.valueKey);

    final dislikeButton = AppGhostButton.icon(
      explicitDocumentUserReaction.isIrrelevant
          ? R.assets.icons.thumbsDownActive
          : R.assets.icons.thumbsDown,
      onPressed: onDislikePressed,
      iconColor: R.colors.brightIcon,
    ).withSemanticsLabel(
        '${Keys.navBarItemDisLike.valueKey} = ${explicitDocumentUserReaction.isIrrelevant}');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (feedType != FeedType.deepSearch) likeButton,
        if (feedType != FeedType.deepSearch) deepSearchButton,
        shareButton,
        if (feedType != FeedType.deepSearch) dislikeButton,
      ],
    );
  }
}
