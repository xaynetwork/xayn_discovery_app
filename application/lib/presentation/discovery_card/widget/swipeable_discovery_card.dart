import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

const kSwipeOpenToPosition = 0.35;

enum SwipeOption { like, dislike }

class SwipeableDiscoveryCard extends StatelessWidget {
  const SwipeableDiscoveryCard({
    Key? key,
    required this.document,
    required this.card,
    required this.isPrimary,
    this.isSwipingEnabled = true,
  }) : super(key: key);

  final Document document;
  final Widget card;
  final bool isPrimary;
  final bool isSwipingEnabled;

  @override
  Widget build(BuildContext context) {
    return isSwipingEnabled ? _buildSwipeWidget(card) : card;
  }

  Widget _buildSwipeWidget(Widget child) => Swipe<SwipeOption>(
        optionsLeft: isPrimary ? const [SwipeOption.like] : const [],
        optionsRight: isPrimary ? const [SwipeOption.dislike] : const [],
        onFling: isPrimary ? (options) => options.first : null,
        opensToPosition: kSwipeOpenToPosition,
        child: child,
        onOptionTap: isPrimary ? (option) => onOptionsTap(option) : null,
        optionBuilder: optionsBuilder,
      );

  void onOptionsTap(SwipeOption option) {
    final DiscoveryCardActionsManager actionsManager = di.get();

    switch (option) {
      case SwipeOption.like:
        actionsManager.likeDocument(document);
        break;
      case SwipeOption.dislike:
        actionsManager.dislikeDocument(document);
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

  Color getColor(SwipeOption option) => option == SwipeOption.dislike
      ? R.colors.swipeBackgroundDelete
      : R.colors.swipeBackgroundRelevant;

  Widget getAsset(SwipeOption option) => option == SwipeOption.dislike
      ? SvgPicture.asset(
          R.assets.icons.thumbsDown,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        )
      : SvgPicture.asset(
          R.assets.icons.thumbsUp,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
}
