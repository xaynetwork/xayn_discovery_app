import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/web_resource.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import 'favicon_bar.dart';
import 'package:xayn_design/xayn_design.dart';

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.title,
    required this.provider,
    required this.datePublished,
    required this.actionButtonRow,
    required this.onFooterPressed,
  }) : super(key: key);
  final String title;
  final WebResourceProvider? provider;
  final DateTime datePublished;
  final ButtonRowFooter actionButtonRow;
  final VoidCallback? onFooterPressed;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: R.styles.appScreenHeadline?.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );

    return InkWell(
      onTap: onFooterPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titleWidget,
            SizedBox(height: R.dimen.unit2),
            if (provider != null)
              FaviconBar(
                provider: provider!,
                datePublished: datePublished,
              ),
            SizedBox(height: R.dimen.unit2),
            actionButtonRow,
            SizedBox(height: R.dimen.unit5),
          ],
        ),
      ),
    );
  }
}

class ButtonRowFooter extends StatelessWidget {
  const ButtonRowFooter({
    Key? key,
    this.onSharePressed,
    this.onLikePressed,
    this.onDislikePressed,
  }) : super(key: key);
  final VoidCallback? onSharePressed;
  final VoidCallback? onLikePressed;
  final VoidCallback? onDislikePressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: R.dimen.unit4,
      children: [
        IconButton(
          onPressed: onLikePressed,
          icon: SvgPicture.asset(
            R.assets.icons.thumbsUp,
            fit: BoxFit.none,
            color: R.colors.brightIcon,
          ),
        ),
        IconButton(
          onPressed: onSharePressed,
          icon: SvgPicture.asset(
            R.assets.icons.share,
            fit: BoxFit.none,
            color: R.colors.brightIcon,
          ),
        ),
        IconButton(
          onPressed: onDislikePressed,
          icon: SvgPicture.asset(
            R.assets.icons.thumbsDown,
            fit: BoxFit.none,
            color: R.colors.brightIcon,
          ),
        ),
      ],
    );
  }
}
