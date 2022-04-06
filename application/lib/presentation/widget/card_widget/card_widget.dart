import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';
import 'package:xayn_discovery_app/presentation/widget/card_widget/card_data.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';

class CardWidgetData {
  const CardWidgetData._();

  static const double cardHeight = 150.0;
  static const double cardWidth = cardHeight * 2;
}

class CardWidget extends StatelessWidget {
  final CardData cardData;

  CardWidget({
    required this.cardData,
  }) : super(
          key: cardData.key,
        );

  BorderRadius getCardRadius(BuildContext context) =>
      UnterDenLinden.getLinden(context).styles.roundBorderCard;

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
      bookmark: (data) => _buildBookmarkCardContent(
        title: data.title,
        created: data.created,
        provider: data.provider,
      ),
    );

    /// Refactored signature to get rid of dynamic type
    Widget withBackgroundImage({
      Uint8List? backgroundImage,
      double? width,
    }) {
      buildMemoryImage(Uint8List bytes) => Container(
            foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                R.colors.swipeCardBackgroundDefault.withAlpha(120),
                R.colors.swipeCardBackgroundDefault.withAlpha(40),
                R.colors.swipeCardBackgroundDefault.withAlpha(255),
                R.colors.swipeCardBackgroundDefault.withAlpha(255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [.0, .15, 8, 1.0],
            )),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: width,
              height: CardWidgetData.cardHeight,
            ),
          );

      return backgroundImage != null
          ? ClipRRect(
              borderRadius: getCardRadius(context),
              child: buildMemoryImage(backgroundImage),
            )
          : SvgPicture.asset(
              R.assets.graphics.formsEmptyCollection,
              height: CardWidgetData.cardHeight,
            );
    }

    final Widget background = cardData.map(
      personalArea: (data) => SvgPicture.asset(
        data.svgBackgroundPath,
        height: CardWidgetData.cardHeight,
      ),
      collectionsScreen: (it) => withBackgroundImage(
        backgroundImage: it.backgroundImage,
        width: it.cardWidth,
      ),
      bookmark: (it) => withBackgroundImage(
        backgroundImage: it.backgroundImage,
        width: it.cardWidth,
      ),
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

    final onLongPressed = cardData.map(
      collectionsScreen: (data) => data.onLongPressed,
      bookmark: (data) => data.onLongPressed,
      personalArea: (data) => null,
    );

    return AppGhostButton(
      contentPadding: EdgeInsets.zero,
      onPressed: cardData.onPressed,
      onLongPressed: onLongPressed,
      child: item,
      borderRadius: getCardRadius(context),
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
      style: R.styles.lBoldStyle.copyWith(color: R.colors.brightText),
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
      style: R.styles.lBoldStyle.copyWith(color: R.colors.brightText),
    );

    final articleText =
        numOfItems == 1 ? R.strings.article : R.strings.articles;

    final numOfItemsText = Text(
      numOfItems.toString() + ' ' + articleText,
      style: R.styles.mStyle.copyWith(color: R.colors.brightText),
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
    DocumentProvider? provider,
  }) {
    final favicon = provider?.favicon == null
        ? Icon(Icons.web, color: R.colors.icon)
        : Image.network(
            provider!.favicon!.toString(),
            width: R.dimen.unit2,
            height: R.dimen.unit2,
            errorBuilder: (_, __, ___) => Thumbnail.icon(Icons.web),
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
        Flexible(
          child: Text(
            provider?.name ?? '',
            style: R.styles.sBoldStyle.copyWith(color: R.colors.brightText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: R.dimen.unit,
        ),
        Text(
          '•',
          style: R.styles.sBoldStyle.copyWith(color: R.colors.brightText),
        ),
        SizedBox(
          width: R.dimen.unit,
        ),
        Text(
          timeAgo(created, DateFormat.yMMMMd()),
          style: R.styles.sStyle.copyWith(color: R.colors.brightText),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final secondRow = Text(
      title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: R.styles.lBoldStyle.copyWith(color: R.colors.brightText),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [firstRow, secondRow],
    );
  }
}
