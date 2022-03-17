import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

final BorderRadius _kBorderRadius = BorderRadius.circular(R.dimen.unit1_5);
final double _kItemSpacing = R.dimen.unit;
final EdgeInsets _kPadding = EdgeInsets.symmetric(horizontal: R.dimen.unit);

class ShimmeringFeedView extends StatelessWidget {
  final double notchSize;
  final double mainCardSize;
  final double itemSpacing;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  late final NewsResource _resource = NewsResource(
    title: '',
    snippet: '',
    url: Uri.base,
    sourceDomain: '',
    image: Uri.base,
    datePublished: DateTime.fromMicrosecondsSinceEpoch(0),
    rank: -1,
    score: -1,
    country: '',
    language: '',
    topic: '',
  );
  late final Document document = Document(
    documentId: DocumentId(),
    resource: _resource,
    batchIndex: -1,
    userReaction: UserReaction.neutral,
  );
  late final isInTest = Platform.environment.containsKey('FLUTTER_TEST');

  ShimmeringFeedView({
    Key? key,
    required this.notchSize,
    double fullScreenOffsetFraction = .0,
  })  : mainCardSize = notchSize,
        padding = _kPadding,
        itemSpacing = _kItemSpacing,
        borderRadius = _kBorderRadius,
        super(key: key);

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: R.colors.searchResultSkeletonBase,
        highlightColor: R.colors.searchResultSkeletonHighlight,
        enabled: !isInTest,
        child: CardView(
          scrollDirection: Axis.vertical,
          size: mainCardSize,
          padding: padding,
          itemBuilder: _itemBuilder(true),
          secondaryItemBuilder: _itemBuilder(false),
          itemCount: 2,
          itemSpacing: itemSpacing,
          clipBorderRadius: borderRadius,
          disableGestures: true,
          animationDuration: R.animations.feedTransitionDuration,
        ),
      );

  Widget Function(BuildContext, int) _itemBuilder(bool isPrimary) =>
      (BuildContext context, int index) => ColoredBox(
            color: R.colors.cardBackground,
            child: DiscoveryFeedCard(
              isPrimary: isPrimary,
              document: document,
            ),
          );
}
