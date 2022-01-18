import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_data.freezed.dart';

@freezed
class CardData with _$CardData {
  const factory CardData.personalArea({
    required Key key,
    required String title,
    required Color color,
    required String svgIconPath,
    required String svgBackground,
    required VoidCallback onPressed,
  }) = _CardDataPersonalArea;

  const factory CardData.collectionsScreen({
    required Key key,
    required String title,
    required VoidCallback onPressed,
    required VoidCallback onLongPressed,
    required int numOfItems,
    required Color color,
    required double cardWidth,
    Uint8List? backgroundImage,
  }) = _CardDataCollectionsScreen;

  const factory CardData.bookmark({
    required Key key,
    required String title,
    required VoidCallback onPressed,
    required VoidCallback onLongPressed,
    required DateTime created,
    required double cardWidth,
    String? providerName,
    Uint8List? faviconImage,
    Uint8List? backgroundImage,
  }) = _CardDataBookmark;
}
