import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_data.dart';

const _itemHeight = 150.0;

class CardWidget extends StatelessWidget {
  final CardData cardData;
  const CardWidget({
    required this.cardData,
    Key? key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    final contentPadding = R.dimen.unit3;

    final cardContent = cardData.map(
      personalArea: (data) => _buildPersonalAreaCardContent(
        title: data.title,
        color: data.color,
        svgIconPath: data.svgIconPath,
        svgBackground: data.svgBackgroundPath,
        onPressed: data.onPressed,
      ),
      collectionsScreen: (data) => _buildCollectionsScreenCardContent(
        title: data.title,
        numOfItems: data.numOfItems,
      ),
    );

    final Widget background = cardData.map(
      personalArea: (data) => SvgPicture.asset(
        data.svgBackgroundPath,
        height: _itemHeight,
      ),
      collectionsScreen: (data) => data.backgroundImage != null
          ? ClipRRect(
              borderRadius:
                  UnterDenLinden.getLinden(context).styles.roundBorder1_5,
              child: Image.memory(
                data.backgroundImage!,
                fit: BoxFit.cover,
                height: _itemHeight,
              ),
            )
          : SvgPicture.asset(
              ///TODO this is temporary, the right assets will be added when ready
              R.assets.graphics.formsOrange,
              height: _itemHeight,
            ),
    );

    final stack = Stack(
      children: [
        Positioned.fill(
          left: cardData.map(
            personalArea: (_) => null,
            collectionsScreen: (_) => 0.0,
          ),
          child: background,
        ),
        Positioned(
          left: contentPadding,
          bottom: contentPadding,
          right: contentPadding,
          child: cardContent,
        ),
      ],
    );

    final item = SizedBox(
      height: _itemHeight,
      child: stack,
    );

    final onLongPressed =
        cardData.mapOrNull(collectionsScreen: (data) => data.onLongPressed);

    return AppGhostButton(
      contentPadding: EdgeInsets.zero,
      onPressed: cardData.onPressed,
      onLongPressed: onLongPressed,
      child: item,
      borderRadius: UnterDenLinden.getLinden(context).styles.roundBorder1_5,
      backgroundColor: cardData.color,
    );
  }

  Widget _buildPersonalAreaCardContent({
    required String title,
    required Color color,
    required String svgIconPath,
    required String svgBackground,
    required onPressed,
  }) {
    final icon = SvgPicture.asset(
      svgIconPath,
      color: R.colors.iconInverse,
      width: R.dimen.iconSize,
      height: R.dimen.iconSize,
    );
    final titleText = Text(
      title,
      style: R.styles.appHeadlineText
          ?.copyWith(color: R.colors.primaryTextInverse),
    );
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        icon,
        SizedBox(height: R.dimen.unit),
        titleText,
      ],
    );

    return column;
  }

  Widget _buildCollectionsScreenCardContent({
    required String title,
    required int numOfItems,
  }) {
    final titleText = Text(
      title,
      style: R.styles.appHeadlineText
          ?.copyWith(color: R.colors.primaryTextInverse),
    );

    final articleText =
        numOfItems == 1 ? R.strings.article : R.strings.articles;

    final numOfItemsText = Text(
      numOfItems.toString() + ' ' + articleText,
      style: R.styles.appBodyText?.copyWith(color: R.colors.primaryTextInverse),
    );

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        titleText,
        numOfItemsText,
      ],
    );
    return row;
  }
}
