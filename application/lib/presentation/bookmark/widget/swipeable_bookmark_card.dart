import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

const double _kSwipeOpenToPosition = 0.35;
const double _kMinFlingVelocity = 250.0;

enum SwipeOption { move, delete }

class SwipeableBookmarkCard extends StatelessWidget {
  const SwipeableBookmarkCard({
    Key? key,
    required this.child,
    required this.bookmarkId,
    required this.onMove,
    required this.onDelete,
  }) : super(key: key);

  final UniqueId bookmarkId;
  final Widget child;
  final Function(UniqueId) onMove;
  final Function(UniqueId) onDelete;
  final double cardHeight = 150;

  @override
  Widget build(BuildContext context) => _buildSwipeWidget(child);

  Widget _buildSwipeWidget(Widget child) {
    final swipe = Swipe<SwipeOption>(
      optionsLeft: const [SwipeOption.move],
      optionsRight: const [SwipeOption.delete],
      minFlingVelocity: _kMinFlingVelocity,
      minFlingDragDistanceFraction: .333,
      onFling: (options) => options.first,
      opensToPosition: _kSwipeOpenToPosition,
      child: child,
      onOptionTap: (option) => onOptionsTap(option),
      optionBuilder: optionsBuilder,
      waitBeforeClosingDuration: Duration.zero,
    );
    return SizedBox(
      height: CardWidgetData.cardHeight,
      child: ClipRRect(
        borderRadius: R.styles.roundBorder1_5,
        child: swipe,
      ),
    );
  }

  void onOptionsTap(SwipeOption option) {
    switch (option) {
      case SwipeOption.move:
        onMove(bookmarkId);
        break;
      case SwipeOption.delete:
        onDelete(bookmarkId);
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
      case SwipeOption.move:
        return R.colors.swipeBackgroundEdit;
      case SwipeOption.delete:
        return R.colors.swipeBackgroundDelete;
    }
  }

  Widget getAsset(SwipeOption option) {
    switch (option) {
      case SwipeOption.move:
        return SvgPicture.asset(
          R.assets.icons.move,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
      case SwipeOption.delete:
        return SvgPicture.asset(
          R.assets.icons.trash,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
    }
  }
}
