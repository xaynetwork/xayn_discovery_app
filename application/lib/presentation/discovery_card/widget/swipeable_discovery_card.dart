import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

const double _kSwipeOpenToPosition = 0.35;
const double _kMinFlingVelocity = 250.0;

enum SwipeOption { like, neutral, dislike }
typedef OnSwipe = Function(SwipeOption swipeOption);

class SwipeableDiscoveryCard extends StatelessWidget {
  const SwipeableDiscoveryCard({
    Key? key,
    required this.onSwipe,
    required this.document,
    required this.explicitDocumentUserReaction,
    required this.card,
    required this.isPrimary,
    this.isSwipingEnabled = true,
    this.onFling,
  }) : super(key: key);

  final OnSwipe onSwipe;
  final Document document;
  final UserReaction explicitDocumentUserReaction;
  final Widget card;
  final bool isPrimary;
  final bool isSwipingEnabled;
  final VoidCallback? onFling;

  @override
  Widget build(BuildContext context) {
    return isSwipingEnabled ? _buildSwipeWidget(card) : card;
  }

  Widget _buildSwipeWidget(Widget child) => Swipe<SwipeOption>(
        optionsLeft: isPrimary
            ? [
                explicitDocumentUserReaction.isRelevant
                    ? SwipeOption.neutral
                    : SwipeOption.like
              ]
            : const [],
        optionsRight: isPrimary
            ? [
                explicitDocumentUserReaction.isIrrelevant
                    ? SwipeOption.neutral
                    : SwipeOption.dislike
              ]
            : const [],
        minFlingVelocity: _kMinFlingVelocity,
        minFlingDragDistanceFraction: .333,
        onFling: isPrimary
            ? (options) {
                onFling?.call();
                return options.first;
              }
            : null,
        opensToPosition: _kSwipeOpenToPosition,
        child: ClipRRect(
          child: card,
          borderRadius: BorderRadius.circular(R.dimen.unit1_5),
        ),
        onOptionTap: isPrimary ? (option) => onOptionsTap(option) : null,
        optionBuilder: optionsBuilder,
        waitBeforeClosingDuration: Duration.zero,
      );

  void onOptionsTap(SwipeOption option) {
    onSwipe(option);
  }

  SwipeOptionContainer<SwipeOption> optionsBuilder(
    BuildContext context,
    SwipeOption option,
    int index,
    bool selected,
  ) =>
      SwipeOptionContainer(
        option: option,
        color: getColor(option),
        child: getAsset(option),
      );

  Color getColor(SwipeOption option) {
    switch (option) {
      case SwipeOption.like:
        return R.colors.swipeBackgroundRelevant;
      case SwipeOption.neutral:
        return R.colors.swipeBackgroundNeutral;
      case SwipeOption.dislike:
        return R.colors.swipeBackgroundIrrelevant;
    }
  }

  Widget getAsset(SwipeOption option) {
    switch (option) {
      case SwipeOption.like:
        return SvgPicture.asset(
          R.assets.icons.thumbsUp,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
      case SwipeOption.neutral:
        return SvgPicture.asset(
          R.assets.icons.neutral,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
      case SwipeOption.dislike:
        return SvgPicture.asset(
          R.assets.icons.thumbsDown,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
    }
  }
}
