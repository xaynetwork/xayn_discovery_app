import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/web_resource.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';

import 'favicon_bar.dart';
import 'package:xayn_design/xayn_design.dart';

typedef ReaderModeBuilder = Widget Function();

const double kReaderModeStartOffset = 200.0;
const double kTitleReaderModeSize = 17.0;
const double kTitleNormalSize = 24.0;

class DiscoveryCardFooter extends StatelessWidget {
  const DiscoveryCardFooter({
    Key? key,
    required this.title,
    required this.url,
    required this.datePublished,
    required this.shouldDisplayReaderMode,
    required this.readerModeBuilder,
    this.provider,
    this.onFooterPressed,
    this.onTitlePressed,
  }) : super(key: key);
  final String title;
  final Uri url;
  final bool shouldDisplayReaderMode;
  final ReaderModeBuilder readerModeBuilder;
  final WebResourceProvider? provider;
  final DateTime datePublished;
  final VoidCallback? onFooterPressed;
  final VoidCallback? onTitlePressed;

  @override
  Widget build(BuildContext context) {
    final DiscoveryCardManager _discoveryCardManager = di.get();

    final titleWidget = InkWell(
      onTap: onTitlePressed,
      child: Text(
        title,
        style: R.styles.appScreenHeadline?.copyWith(
          color: Colors.white,
          fontSize:
              shouldDisplayReaderMode ? kTitleReaderModeSize : kTitleNormalSize,
        ),
        textAlign: TextAlign.center,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );

    final actionButtonRow = _ButtonRowFooter(
      onSharePressed: () => _discoveryCardManager.shareUri(url),
      onLikePressed: () => debugPrint('Like is pressed'),
      onDislikePressed: () => debugPrint('Dislike is pressed'),
    );

    final faviconRow = FaviconBar(
      provider: provider!,
      datePublished: datePublished,
    );

    final footerColumn = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (shouldDisplayReaderMode)
          const SizedBox(height: kReaderModeStartOffset),
        titleWidget,
        SizedBox(height: R.dimen.unit2),
        if (shouldDisplayReaderMode) ...[
          Expanded(child: readerModeBuilder()),
          SizedBox(height: R.dimen.unit2),
        ],
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
