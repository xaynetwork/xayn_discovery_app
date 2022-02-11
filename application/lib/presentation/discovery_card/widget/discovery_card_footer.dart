import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.onSharePressed,
    required this.onLikePressed,
    required this.onDislikePressed,
    required this.onBookmarkPressed,
    required this.onBookmarkLongPressed,
    required this.isBookmarked,
    required this.document,
    required this.explicitDocumentFeedback,
  }) : super(key: key);

  final VoidCallback onSharePressed;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onBookmarkLongPressed;
  final bool isBookmarked;
  final Document document;
  final DocumentFeedback explicitDocumentFeedback;

  @override
  Widget build(BuildContext context) {
    final likeButton = AppGhostButton.icon(
      explicitDocumentFeedback.isRelevant
          ? R.assets.icons.thumbsUpActive
          : R.assets.icons.thumbsUp,
      onPressed: onLikePressed,
      iconColor: R.colors.brightIcon,
    );

    final bookmarkButton = AppGhostButton.icon(
      isBookmarked ? R.assets.icons.bookmarkActive : R.assets.icons.bookmark,
      onPressed: onBookmarkPressed,
      onLongPressed: onBookmarkLongPressed,
      iconColor: R.colors.brightIcon,
    );

    final shareButton = AppGhostButton.icon(
      R.assets.icons.share,
      onPressed: onSharePressed,
      iconColor: R.colors.brightIcon,
    );

    final dislikeButton = AppGhostButton.icon(
      explicitDocumentFeedback.isIrrelevant
          ? R.assets.icons.thumbsDownActive
          : R.assets.icons.thumbsDown,
      onPressed: onDislikePressed,
      iconColor: R.colors.brightIcon,
    );

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
