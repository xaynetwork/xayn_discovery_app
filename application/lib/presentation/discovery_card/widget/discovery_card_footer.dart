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
  }) : super(key: key);
  final String title;
  final WebResourceProvider? provider;
  final DateTime datePublished;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: R.styles.appScreenHeadline?.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );

    return Column(
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
        const ButtonRowFooter(),
      ],
    );
  }
}

class ButtonRowFooter extends StatelessWidget {
  const ButtonRowFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: R.dimen.unit4,
      children: [
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            R.assets.icons.thumbsUp,
            fit: BoxFit.none,
            color: R.colors.brightIcon,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            R.assets.icons.share,
            fit: BoxFit.none,
            color: R.colors.brightIcon,
          ),
        ),
        IconButton(
          onPressed: () {},
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
