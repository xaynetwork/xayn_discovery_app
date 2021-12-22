import 'package:flutter/widgets.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

const Duration _kAnimationDuration = Duration(milliseconds: 800);
const Curve _kAnimationCurve = Curves.elasticOut;
const double _kCardNotchSize = .93;
final BorderRadius _kBorderRadius = BorderRadius.circular(R.dimen.unit1_5);
final double _kItemSpacing = R.dimen.unit1_5;
final EdgeInsets _kPadding = EdgeInsets.symmetric(
  horizontal: R.dimen.unit2,
);

/// Extended version of [ListView] intended to display [DiscoveryCard]s.
/// All items are displayed full screen with vertical scrolling.
class FeedView extends StatelessWidget {
  final bool isFullScreen;
  final double notchSize;

  FeedView({
    Key? key,
    required this.itemBuilder,
    required this.isFullScreen,
    double fullScreenOffsetFraction = .0,
    this.scrollDirection = Axis.vertical,
    this.onFinalIndex,
    this.onIndexChanged,
    this.cardViewController,
    this.secondaryItemBuilder,
    this.itemCount,
    this.notchSize = _kCardNotchSize,
  })  : mainCardSize = isFullScreen
            ? 1.0 - .15 * fullScreenOffsetFraction
            : _kCardNotchSize,
        padding = isFullScreen
            ? EdgeInsets.symmetric(
                horizontal: R.dimen.unit3 * fullScreenOffsetFraction)
            : _kPadding,
        itemSpacing = isFullScreen
            ? R.dimen.unit3 * fullScreenOffsetFraction
            : _kItemSpacing,
        borderRadius = isFullScreen
            ? BorderRadius.all(
                Radius.circular(fullScreenOffsetFraction * R.dimen.unit1_5))
            : _kBorderRadius,
        super(key: key);

  final CardViewController? cardViewController;
  final Axis scrollDirection;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? secondaryItemBuilder;
  final VoidCallback? onFinalIndex;
  final IndexChangedCallback? onIndexChanged;
  final int? itemCount;

  final double mainCardSize;
  final double itemSpacing;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => CardView(
        animationDuration: _kAnimationDuration,
        animationCurve: _kAnimationCurve,
        animateToSnapDuration: R.animations.unit2,
        scrollDirection: scrollDirection,
        controller: cardViewController,
        size: mainCardSize,
        padding: padding,
        itemBuilder: itemBuilder,
        secondaryItemBuilder: secondaryItemBuilder,
        itemCount: itemCount ?? 0,
        itemSpacing: itemSpacing,
        clipBorderRadius: borderRadius,
        onFinalIndex: onFinalIndex,
        onIndexChanged: onIndexChanged,
        disableGestures: isFullScreen,
      );
}
