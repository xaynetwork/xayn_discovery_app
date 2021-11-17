import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/web_resource.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import 'favicon_bar.dart';
import 'package:xayn_design/xayn_design.dart';

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.title,
    required this.url,
    required this.provider,
    required this.datePublished,
    required this.onFooterPressed,
  }) : super(key: key);
  final String title;
  final Uri url;
  final WebResourceProvider? provider;
  final DateTime datePublished;
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
            _ButtonRowFooter(
              onSharePressed: () => Share.share(url.toString()),
              onLikePressed: () => debugPrint('Like is pressed'),
              onDislikePressed: () => debugPrint('Dislike is pressed'),
            ),
            SizedBox(height: R.dimen.unit7),
          ],
        ),
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
  Widget build(BuildContext context) => Wrap(
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
