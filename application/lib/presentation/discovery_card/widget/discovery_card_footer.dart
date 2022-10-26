import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/utils/semantics_extension.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.onSharePressed,
    required this.onLikePressed,
    required this.onDislikePressed,
    required this.onBookmarkPressed,
    required this.onBookmarkLongPressed,
    required this.bookmarkStatus,
    required this.document,
    required this.explicitDocumentUserReaction,
  }) : super(key: key);

  final VoidCallback onSharePressed;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onBookmarkLongPressed;
  final BookmarkStatus bookmarkStatus;
  final Document document;
  final UserReaction explicitDocumentUserReaction;

  @override
  Widget build(BuildContext context) {
    final likeButton = AppGhostButton.icon(
      explicitDocumentUserReaction.isRelevant
          ? R.assets.icons.thumbsUpActive
          : R.assets.icons.thumbsUp,
      onPressed: onLikePressed,
      iconColor: R.colors.icon,
    ).withSemanticsLabel(
      '${Keys.navBarItemLike.valueKey} = ${explicitDocumentUserReaction.isRelevant}',
    );

    final bookmarkButton = AppGhostButton.icon(
      bookmarkStatus == BookmarkStatus.bookmarked
          ? R.assets.icons.bookmarkActive
          : R.assets.icons.bookmark,
      onPressed: onBookmarkPressed,
      onLongPressed: onBookmarkLongPressed,
      iconColor: R.colors.icon,
    ).withSemanticsLabel(
      '${Keys.navBarItemBookmark.valueKey} = ${explicitDocumentUserReaction.isRelevant}',
    );

    final shareButton = AppGhostButton.icon(
      R.assets.icons.share,
      onPressed: onSharePressed,
      iconColor: R.colors.icon,
    ).withSemanticsLabel(Keys.navBarItemShare.valueKey);

    final dislikeButton = AppGhostButton.icon(
      explicitDocumentUserReaction.isIrrelevant
          ? R.assets.icons.thumbsDownActive
          : R.assets.icons.thumbsDown,
      onPressed: onDislikePressed,
      iconColor: R.colors.icon,
    ).withSemanticsLabel(
        '${Keys.navBarItemDisLike.valueKey} = ${explicitDocumentUserReaction.isIrrelevant}');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        likeButton,
        bookmarkButton,
        shareButton,
        dislikeButton,
      ],
    );
  }
}
