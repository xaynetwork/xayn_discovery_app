import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/web_resource.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';

import 'favicon_bar.dart';
import 'package:xayn_design/xayn_design.dart';

/// Defines how wide the title may be.
/// During animation transitions, the card itself will grow or shrink.
/// the title needs to be "static", as in, we don't want it to grow or shrink
/// together with the card, otherwise during animation, the text will adapt and
/// suddenly take up less or more lines for example.
/// Instead, the title width is static, based on the device's width and not the
/// card's width.
const double _kMaxTitleFraction = .75;

class DiscoveryCardElements extends StatelessWidget {
  const DiscoveryCardElements({
    Key? key,
    required this.title,
    required this.timeToRead,
    required this.url,
    required this.datePublished,
    this.provider,
    required this.onLikePressed,
    required this.onDislikePressed,
    this.fractionSize = 1.0,
  }) : super(key: key);
  final String title;
  final String timeToRead;
  final Uri url;
  final WebResourceProvider? provider;
  final DateTime datePublished;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;
  final double fractionSize;

  @override
  Widget build(BuildContext context) {
    final DiscoveryCardActionsManager _actionsManager = di.get();
    final mediaQuery = MediaQuery.of(context);
    final timeToReadWidget = Text(
      '$timeToRead ${Strings.readingTimeSuffix}',
      style: R.styles.appBodyText?.copyWith(color: Colors.white),
      textAlign: TextAlign.left,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
    final titleWidget = Text(
      title,
      style: R.styles.appScreenHeadline?.copyWith(color: Colors.white),
      textAlign: TextAlign.left,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );

    final actionButtonRow = Padding(
      padding: EdgeInsets.symmetric(
        vertical: R.dimen.unit3,
      ),
      child: _ButtonRowFooter(
        onSharePressed: () => _actionsManager.shareUri(url),
        onLikePressed: onLikePressed,
        onDislikePressed: onDislikePressed,
      ),
    );

    final faviconRow = FaviconBar(
      provider: provider!,
      datePublished: datePublished,
    );

    final titleAndTimeToRead = Wrap(
      runAlignment: WrapAlignment.end,
      runSpacing: R.dimen.unit,
      children: [
        if (timeToRead.isNotEmpty) timeToReadWidget,
        SizedBox(
          width: mediaQuery.size.width * _kMaxTitleFraction,
          child: titleWidget,
        ),
      ],
    );

    final elements = Padding(
      padding: EdgeInsets.all(R.dimen.unit3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider != null) faviconRow,
          Expanded(child: titleAndTimeToRead),
          ClipRRect(
            child: SizedBox(
              width: double.infinity,
              height: R.dimen.unit12 * fractionSize,
              child: actionButtonRow,
            ),
          ),
        ],
      ),
    );

    return elements;
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
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: R.dimen.unit4,
      children: [
        likeButton,
        shareButton,
        dislikeButton,
      ],
    );
  }
}
