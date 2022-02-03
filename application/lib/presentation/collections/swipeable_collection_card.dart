import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

enum SwipeOptionCollectionCard {
  edit,
  remove,
}

typedef OnSwipeOptionTap = Map<SwipeOptionCollectionCard, VoidCallback>;

const double _kSwipeOpenToPosition = 0.35;
const double _kMinFlingVelocity = 250.0;

class SwipeableCollectionCard extends StatelessWidget {
  const SwipeableCollectionCard({
    required this.collectionCard,
    required this.onSwipeOptionTap,
    this.cardHeight = CardWidgetData.cardHeight,
    Key? key,
  }) : super(key: key);

  final Widget collectionCard;
  final double cardHeight;
  final OnSwipeOptionTap onSwipeOptionTap;

  @override
  Widget build(BuildContext context) {
    final swipeableCard = Swipe<SwipeOptionCollectionCard>(
      minFlingVelocity: _kMinFlingVelocity,
      opensToPosition: _kSwipeOpenToPosition,
      optionsLeft: const [SwipeOptionCollectionCard.edit],
      optionsRight: const [SwipeOptionCollectionCard.remove],
      onFling: (options) => options.first,
      onOptionTap: _onOptionsTap,
      optionBuilder: optionsBuilder,
      waitBeforeClosingDuration: Duration.zero,
      child: collectionCard,
    );
    return SizedBox(
      height: cardHeight,
      child: ClipRRect(
        borderRadius: R.styles.roundBorder1_5,
        child: swipeableCard,
      ),
    );
  }

  SwipeOptionContainer<SwipeOptionCollectionCard> optionsBuilder(
    BuildContext context,
    SwipeOptionCollectionCard option,
    int index,
    bool selected,
  ) =>
      SwipeOptionContainer(
        option: option,
        color: _getColor(option),
        child: _getAsset(option),
      );

  void _onOptionsTap(SwipeOptionCollectionCard option) {
    switch (option) {
      case SwipeOptionCollectionCard.edit:
        final onTap = onSwipeOptionTap[SwipeOptionCollectionCard.edit];
        onTap!();
        return;

      case SwipeOptionCollectionCard.remove:
        final onTap = onSwipeOptionTap[SwipeOptionCollectionCard.remove];
        onTap!();
        return;
    }
  }

  Color _getColor(SwipeOptionCollectionCard option) {
    switch (option) {
      case SwipeOptionCollectionCard.edit:
        return R.colors.swipeBackgroundEdit;
      case SwipeOptionCollectionCard.remove:
        return R.colors.swipeBackgroundDelete;
    }
  }

  Widget _getAsset(SwipeOptionCollectionCard option) {
    switch (option) {
      case SwipeOptionCollectionCard.edit:
        return SvgPicture.asset(
          R.assets.icons.edit,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
      case SwipeOptionCollectionCard.remove:
        return SvgPicture.asset(
          R.assets.icons.trash,
          fit: BoxFit.none,
          color: R.colors.brightIcon,
        );
    }
  }
}
