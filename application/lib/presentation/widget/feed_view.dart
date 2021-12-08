import 'package:flutter/material.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// Extended version of [ListView] intended to display [DiscoveryCard]s.
/// All items are displayed full screen with vertical scrolling.
class FeedView extends StatelessWidget {
  const FeedView({
    Key? key,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.onFinalIndex,
    this.onIndexChanged,
    this.cardViewController,
    this.secondaryItemBuilder,
    this.itemCount,
  }) : super(key: key);

  final CardViewController? cardViewController;
  final Axis scrollDirection;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? secondaryItemBuilder;
  final VoidCallback? onFinalIndex;
  final IndexChangedCallback? onIndexChanged;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final bottomPadding =
        scrollDirection == Axis.horizontal ? padding.bottom : 0.0;
    return Padding(
      padding: EdgeInsets.only(top: padding.top, bottom: bottomPadding),
      child: LayoutBuilder(builder: (context, constraints) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: CardView(
            animateToSnapDuration: R.animations.unit2,
            scrollDirection: scrollDirection,
            controller: cardViewController,
            size: .947,
            itemBuilder: itemBuilder,
            secondaryItemBuilder: secondaryItemBuilder,
            itemCount: itemCount ?? 0,
            itemSpacing: .0,
            clipBorderRadius: const BorderRadius.all(Radius.zero),
            onFinalIndex: onFinalIndex,
            onIndexChanged: onIndexChanged,
          ),
        );
      }),
    );
  }
}
