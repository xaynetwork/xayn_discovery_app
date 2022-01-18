import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_data.dart';

class CardWidgetData {
  const CardWidgetData._();

  static const double cardHeight = 150.0;
}

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
        svgBackground: data.svgBackground,
        onPressed: data.onPressed,
      ),
      collectionsScreen: (data) => _buildCollectionsScreenCardContent(
        title: data.title,
        numOfItems: data.numOfItems,
      ),
      bookmark: (data) => _buildBookmarkCardContent(
        title: data.title,
        created: data.created,
        providerName: data.providerName,
        faviconData: data.faviconImage,
      ),
    );

    Widget withBackgroundImage(data) => data.backgroundImage != null
        ? ClipRRect(
            borderRadius:
                UnterDenLinden.getLinden(context).styles.roundBorder1_5,
            child: Container(
              foregroundDecoration: BoxDecoration(
                gradient: buildGradient(opacity: 0.5),
              ),
              child: Image.memory(
                data.backgroundImage!,
                fit: BoxFit.cover,
                width: data.cardWidth,
                height: CardWidgetData.cardHeight,
              ),
            ),
          )
        : SvgPicture.asset(
            R.assets.graphics.formsEmptyCollection,
            height: CardWidgetData.cardHeight,
          );

    final Widget background = cardData.map(
      personalArea: (data) => SvgPicture.asset(
        data.svgBackground,
        height: CardWidgetData.cardHeight,
      ),
      collectionsScreen: withBackgroundImage,
      bookmark: withBackgroundImage,
    );

    double? noFill(data) => data.backgroundImage != null ? 0.0 : null;
    final stack = Stack(
      children: [
        Positioned.fill(
          left: cardData.map(
            personalArea: (_) => null,
            collectionsScreen: noFill,
            bookmark: noFill,
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
      height: CardWidgetData.cardHeight,
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
      backgroundColor: cardData.map(
        personalArea: (v) => v.color,
        collectionsScreen: (v) => v.color,
        bookmark: (v) => R.colors.accent,
      ),
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

  Widget _buildBookmarkCardContent({
    required String title,
    required DateTime created,
    String? providerName,
    Uint8List? faviconData,
  }) {
    final favicon = faviconData == null
        ? Icon(Icons.web, color: R.colors.icon)
        : Image.memory(
            faviconData,
            width: R.dimen.unit2,
            height: R.dimen.unit2,
          );

    final firstRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(R.dimen.unit0_5),
          child: favicon,
        ),
        SizedBox(
          width: R.dimen.unit,
        ),
        Text(
          providerName ?? '',
          style: R.styles.appThumbnailText?.copyWith(color: Colors.white),
        ),
        SizedBox(
          width: R.dimen.unit,
        ),
        Text(
          '•',
          style: R.styles.appThumbnailText?.copyWith(color: Colors.white),
        ),
        SizedBox(
          width: R.dimen.unit,
        ),
        Text(
          timeAgo(created, DateFormat.yMMMMd()),
          style: R.styles.appThumbnailTextLight?.copyWith(color: Colors.white),
        ),
      ],
    );

    final secondRow = Text(
      title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: R.styles.appHeadlineText
          ?.copyWith(color: R.colors.primaryTextInverse),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [firstRow, secondRow],
    );
  }
}

Gradient buildGradient({double opacity = 1.0}) => LinearGradient(
      colors: [
        R.colors.swipeCardBackground.withAlpha(120),
        R.colors.swipeCardBackground.withAlpha(40),
        R.colors.swipeCardBackground.withAlpha(127 + (128.0 * opacity).floor()),
        R.colors.swipeCardBackground.withAlpha(127 + (128.0 * opacity).floor()),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0, 0.15, 0.8, 1],
    );
