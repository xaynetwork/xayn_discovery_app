import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import 'package:xayn_design/xayn_design.dart';

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.onSharePressed,
    required this.onLikePressed,
    required this.onDislikePressed,
    required this.onBookmarkPressed,
    required this.isBookmarked,
  }) : super(key: key);

  final VoidCallback onSharePressed;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;
  final VoidCallback onBookmarkPressed;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    final likeButton = IconButton(
      onPressed: onLikePressed,
      icon: SvgPicture.asset(
        R.assets.icons.thumbsUp,
        fit: BoxFit.none,
        color: R.colors.brightIcon,
      ),
    );

    final bookmarkButton = IconButton(
      onPressed: onBookmarkPressed,
      icon: SvgPicture.asset(
        isBookmarked ? R.assets.icons.bookmarkActive : R.assets.icons.bookmark,
        fit: BoxFit.none,
        color: R.colors.brightIcon,
      ),
    );

    final shareButton = IconButton(
      onPressed: onSharePressed,
      icon: SvgPicture.asset(
        R.assets.icons.share,
        fit: BoxFit.none,
        color: R.colors.brightIcon,
      ),
    );

    final dislikeButton = IconButton(
      onPressed: onDislikePressed,
      icon: SvgPicture.asset(
        R.assets.icons.thumbsDown,
        fit: BoxFit.none,
        color: R.colors.brightIcon,
      ),
    );

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: R.dimen.unit4,
      children: [
        likeButton,
        bookmarkButton,
        shareButton,
        dislikeButton,
      ],
    );
  }
}
