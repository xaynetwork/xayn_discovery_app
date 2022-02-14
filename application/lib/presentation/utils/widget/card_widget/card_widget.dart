import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_card_headline_image.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_data.dart';
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
      buildMemoryImage(Uint8List bytes) => Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: width,
            height: CardWidgetData.cardHeight,
          );

      return backgroundImage != null
          ? ClipRRect(
              borderRadius:
                  UnterDenLinden.getLinden(context).styles.roundBorder1_5,
              child: DiscoveryCardHeadlineImage(
                child: buildMemoryImage(backgroundImage),
              ),
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
            style: R.styles.appThumbnailText?.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
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
          overflow: TextOverflow.ellipsis,
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
