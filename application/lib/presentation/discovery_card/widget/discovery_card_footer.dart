import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/web_resource.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';

import 'favicon_bar.dart';
import 'package:xayn_design/xayn_design.dart';

typedef ReaderModeBuilder = Widget Function();

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.title,
    required this.url,
    required this.datePublished,
    this.provider,
    this.onFooterPressed,
    this.onLikePressed,
    this.onDislikePressed,
  }) : super(key: key);
  final String title;
  final Uri url;
  final WebResourceProvider? provider;
  final DateTime datePublished;
  final VoidCallback? onFooterPressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onDislikePressed;

  @override
  Widget build(BuildContext context) {
    final DiscoveryCardActionsManager _actionsManager = di.get();

    final titleWidget = Text(
      title,
      style: R.styles.appScreenHeadline?.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );

    final actionButtonRow = _ButtonRowFooter(
      onSharePressed: () => _actionsManager.shareUri(url),
      onLikePressed: onLikePressed ?? (){},
      onDislikePressed: onDislikePressed ?? (){},
    );

    final faviconRow = FaviconBar(
      provider: provider!,
      datePublished: datePublished,
    );

    final footerColumn = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        titleWidget,
        SizedBox(height: R.dimen.unit2),
        if (provider != null) faviconRow,
        SizedBox(height: R.dimen.unit2),
        actionButtonRow,
        SizedBox(height: R.dimen.unit7),
      ],
    );

    return InkWell(
      onTap: onFooterPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: footerColumn,
      ),
    );
  }
}

class _ButtonRowFooter extends StatelessWidget {
  const _ButtonRowFooter({
    Key? key,
    required this.onSharePressed,
    required this.onLikePressed,
    required this.onDislikePressed,
  }) : super(key: key);

  final VoidCallback onSharePressed;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;

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
      spacing: R.dimen.unit4,
      children: [
        likeButton,
        shareButton,
        dislikeButton,
      ],
    );
  }
}
