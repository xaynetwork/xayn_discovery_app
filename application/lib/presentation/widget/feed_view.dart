import 'package:flutter/material.dart';
import 'package:xayn_card_view/xayn_card_view/card_view.dart';
import 'package:xayn_card_view/xayn_card_view/card_view_controller.dart';

/// Extended version of [ListView] intended to display [DiscoveryCard]s.
/// All items are displayed full screen with vertical scrolling.
class FeedView extends StatelessWidget {
  const FeedView({
    Key? key,
    required this.itemBuilder,
    this.cardViewController,
    this.secondaryItemBuilder,
    this.itemCount,
  }) : super(key: key);

  final CardViewController? cardViewController;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? secondaryItemBuilder;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Padding(
      padding: EdgeInsets.only(top: padding.top),
      child: LayoutBuilder(builder: (context, constraints) {
        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: CardView(
            controller: cardViewController,
            size: .947,
            itemBuilder: itemBuilder,
            secondaryItemBuilder: secondaryItemBuilder,
            itemCount: itemCount ?? 0,
            itemSpacing: .0,
            clipBorderRadius: const BorderRadius.all(Radius.zero),
          ),
        );
      }),
    );
  }
}
