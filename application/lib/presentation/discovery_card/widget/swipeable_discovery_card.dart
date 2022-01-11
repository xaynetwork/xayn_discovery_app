import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';

const kSwipeOpenToPosition = 0.35;

enum SwipeOption { like, neutral, dislike }

class SwipeableDiscoveryCard extends StatelessWidget {
  const SwipeableDiscoveryCard({
    Key? key,
    required this.manager,
    required this.document,
    required this.card,
    required this.isPrimary,
    this.isSwipingEnabled = true,
  }) : super(key: key);

  final DiscoveryCardManager manager;
  final Document document;
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
                document.isRelevant ? SwipeOption.neutral : SwipeOption.like,
              ]
            : const [],
        optionsRight: isPrimary
            ? [
                document.isIrrelevant
                    ? SwipeOption.neutral
                    : SwipeOption.dislike,
              ]
            : const [],
        onFling: isPrimary ? (options) => options.first : null,
        opensToPosition: kSwipeOpenToPosition,
        child: child,
        onOptionTap: isPrimary ? (option) => onOptionsTap(option) : null,
        optionBuilder: optionsBuilder,
        waitBeforeClosingDuration: Duration.zero,
      );

  void onOptionsTap(SwipeOption option) {
    switch (option) {
      case SwipeOption.like:
        manager.changeDocumentFeedback(
          documentId: document.documentId,
          feedback: DocumentFeedback.positive,
        );
        break;
      case SwipeOption.neutral:
        manager.changeDocumentFeedback(
          documentId: document.documentId,
          feedback: DocumentFeedback.neutral,
        );
        break;
      case SwipeOption.dislike:
        manager.changeDocumentFeedback(
          documentId: document.documentId,
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
