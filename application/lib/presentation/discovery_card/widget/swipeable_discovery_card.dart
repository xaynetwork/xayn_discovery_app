import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

const double _kSwipeOpenToPosition = 0.35;
const double _kMinFlingVelocity = 250.0;

enum SwipeOption { like, neutral, dislike }

class SwipeableDiscoveryCard extends StatelessWidget {
  const SwipeableDiscoveryCard({
    Key? key,
    required this.manager,
    required this.document,
    required this.explicitDocumentFeedback,
    required this.card,
    required this.isPrimary,
    this.isSwipingEnabled = true,
  }) : super(key: key);

  final DiscoveryCardManager manager;
  final Document document;
  final DocumentFeedback explicitDocumentFeedback;
  final Widget card;
  final bool isPrimary;
  final bool isSwipingEnabled;

  @override
  Widget build(BuildContext context) {
    return isSwipingEnabled ? _buildSwipeWidget(card) : card;
  }

  Widget _buildSwipeWidget(Widget child) => Swipe<SwipeOption>(
        optionsLeft: isPrimary
            ? [
                explicitDocumentFeedback.isRelevant
                    ? SwipeOption.neutral
                    : SwipeOption.like
              ]
            : const [],
        optionsRight: isPrimary
            ? [
                explicitDocumentFeedback.isIrrelevant
                    ? SwipeOption.neutral
                    : SwipeOption.dislike
              ]
            : const [],
        minFlingVelocity: _kMinFlingVelocity,
        minFlingDragDistanceFraction: .333,
        onFling: isPrimary ? (options) => options.first : null,
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
    switch (option) {
      case SwipeOption.like:
        manager.onFeedback(
          document: document,
          feedback: DocumentFeedback.positive,
        );
        break;
      case SwipeOption.neutral:
        manager.onFeedback(
          document: document,
          feedback: DocumentFeedback.neutral,
        );
        break;
      case SwipeOption.dislike:
        manager.onFeedback(
          document: document,
          feedback: DocumentFeedback.negative,
        );
        break;
    }
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
