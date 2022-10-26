import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_footer.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import 'favicon_bar.dart';

/// Defines how wide the title may be.
/// During animation transitions, the card itself will grow or shrink.
/// the title needs to be "static", as in, we don't want it to grow or shrink
/// together with the card, otherwise during animation, the text will adapt and
/// suddenly take up less or more lines for example.
/// Instead, the title width is static, based on the device's width and not the
/// card's width.
const double _kMaxTitleFraction = .25;

class DiscoveryCardElements extends StatelessWidget {
  const DiscoveryCardElements({
    Key? key,
    required this.manager,
    required this.document,
    required this.explicitDocumentUserReaction,
    required this.title,
    required this.timeToRead,
    required this.url,
    required this.datePublished,
    required this.onLikePressed,
    required this.onDislikePressed,
    required this.onBookmarkPressed,
    required this.onBookmarkLongPressed,
    required this.bookmarkStatus,
    required this.onProviderSectionTap,
    required this.onToggleTts,
    required this.feedType,
    this.isInteractionEnabled = true,
    this.fractionSize = 1.0,
    this.provider,
    this.useLargeTitle = true,
  }) : super(key: key);
  final DiscoveryCardManager manager;
  final Document document;
  final UserReaction explicitDocumentUserReaction;
  final String title;
  final String timeToRead;
  final Uri url;
  final DocumentProvider? provider;
  final DateTime datePublished;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onProviderSectionTap;
  final VoidCallback onToggleTts;
  final VoidCallback onBookmarkLongPressed;
  final BookmarkStatus bookmarkStatus;
  final double fractionSize;
  final bool useLargeTitle;
  final bool isInteractionEnabled;
  final FeedType? feedType;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final titleWidgetStyle =
        useLargeTitle ? R.styles.xxlBoldStyle : R.styles.xlBoldStyle;
    final titleWidget = AutoSizeText(
      title,
      style: titleWidgetStyle.copyWith(color: R.colors.primaryText),
      textAlign: TextAlign.center,
      minFontSize: titleWidgetStyle.fontSize! * _kMaxTitleFraction,
      overflow: TextOverflow.ellipsis,
      maxLines: useLargeTitle ? 6 : 4,
    );

    final actionButtonRow = Padding(
      padding: EdgeInsets.symmetric(
        vertical: R.dimen.unit3,
      ),
      child: DiscoveryCardFooter(
        onSharePressed: () => manager.shareDocument(
          document: document,
          feedType: feedType,
        ),
        onLikePressed: onLikePressed,
        onDislikePressed: onDislikePressed,
        onBookmarkPressed: onBookmarkPressed,
        onBookmarkLongPressed: onBookmarkLongPressed,
        bookmarkStatus: bookmarkStatus,
        document: document,
        explicitDocumentUserReaction: explicitDocumentUserReaction,
      ),
    );

    final titleAndTimeToRead = ClipRRect(
      child: Wrap(
        runAlignment: WrapAlignment.center,
        runSpacing: R.dimen.unit,
        children: [
          SizedBox(
            width: mediaQuery.size.width,
            child: Row(
              children: [Expanded(child: titleWidget)],
            ),
          ),
        ],
      ),
    );

    final elements = Padding(
      padding: EdgeInsets.only(
        top: R.dimen.unit2,
        bottom: R.dimen.unit3,
        left: R.dimen.unit3,
        right: R.dimen.unit3,
      ),
      child: ClipRRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: provider?.favicon != null ? 1.0 : .0,
              duration: R.animations.unit2,
              curve: Curves.easeOut,
              child: _buildCardHeader(),
            ),
            SizedBox(height: R.dimen.unit),
            titleAndTimeToRead,
            SizedBox(
              width: double.infinity,
              height: R.dimen.unit12 * fractionSize,
              child: actionButtonRow,
            ),
          ],
        ),
      ),
    );

    return elements;
  }

  Widget _buildCardHeader() {
    final faviconRow = FaviconBar.fromProvider(
      provider: provider,
      datePublished: datePublished,
      timeToRead: '$timeToRead ${R.strings.readingTimeSuffix}',
    );

    maybeWithTap(Widget child, VoidCallback onTap) => Material(
          color: R.colors.transparent,
          child: InkWell(
            onTap: isInteractionEnabled ? onTap : null,
            child: child,
          ),
        );

    return maybeWithTap(faviconRow, onProviderSectionTap);
  }
}
