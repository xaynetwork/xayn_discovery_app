import 'package:flutter/widgets.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

const Curve _kAnimationCurveIn = Curves.linearToEaseOut;
const Curve _kAnimationCurveOut = Curves.elasticOut;
const Curve _kAnimationSnapCurve = Curves.linearToEaseOut;
final BorderRadius _kBorderRadius = BorderRadius.circular(R.dimen.cardRadius);
final double _kItemSpacing = R.dimen.unit;
final EdgeInsets _kPadding = EdgeInsets.symmetric(horizontal: R.dimen.unit);

/// Extended version of [ListView] intended to display [DiscoveryCard]s.
/// All items are displayed full screen with vertical scrolling.
class FeedView extends StatelessWidget {
  final bool isFullScreen;
  final double notchSize;
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
  final BoxBorderBuilder? boxBorderBuilder;
  final CardIdentifierBuilder? cardIdentifierBuilder;
  final AuxiliaryCardBuilder? noItemsBuilder;
  final AuxiliaryCardBuilder? finalItemBuilder;

  FeedView({
    Key? key,
    required this.itemBuilder,
    required this.isFullScreen,
    required this.notchSize,
    double fullScreenOffsetFraction = .0,
    this.scrollDirection = Axis.vertical,
    this.onFinalIndex,
    this.onIndexChanged,
    this.cardViewController,
    this.secondaryItemBuilder,
    this.itemCount,
    this.boxBorderBuilder,
    this.cardIdentifierBuilder,
    this.noItemsBuilder,
    this.finalItemBuilder,
  })  : mainCardSize =
            isFullScreen ? 1.0 - .15 * fullScreenOffsetFraction : notchSize,
        padding = isFullScreen
            ? EdgeInsets.symmetric(
                horizontal: R.dimen.unit3 * fullScreenOffsetFraction)
            : _kPadding,
        itemSpacing = isFullScreen
            ? R.dimen.unit3 * fullScreenOffsetFraction
            : _kItemSpacing,
        borderRadius = isFullScreen
            ? BorderRadius.all(
                Radius.circular(fullScreenOffsetFraction * R.dimen.cardRadius))
            : _kBorderRadius,
        super(key: key);

  @override
  Widget build(BuildContext context) => CardView(
        animationDuration: R.animations.feedTransitionDuration,
        animationCurve: isFullScreen ? _kAnimationCurveIn : _kAnimationCurveOut,
        animateToSnapDuration: R.animations.unit2_25,
        animateToSnapCurve: _kAnimationSnapCurve,
        scrollDirection: scrollDirection,
        controller: cardViewController,
        size: mainCardSize,
        padding: padding,
        itemBuilder: itemBuilder,
        secondaryItemBuilder: secondaryItemBuilder,
        itemCount: itemCount ?? 0,
        itemSpacing: itemSpacing,
        borderBuilder: boxBorderBuilder,
        clipBorderRadius: borderRadius,
        onFinalIndex: onFinalIndex,
        onIndexChanged: onIndexChanged,
        disableGestures: isFullScreen,
        cardIdentifierBuilder: cardIdentifierBuilder,
        deltaThreshold: 15,
        noItemsBuilder: noItemsBuilder,
        finalItemBuilder: finalItemBuilder,
      );
}
