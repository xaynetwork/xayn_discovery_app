import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_data.freezed.dart';

@freezed
class CardData with _$CardData {
  const factory CardData.personalArea({
    required String title,
    required Color color,
    required String svgIconPath,
    required String svgBackground,
    required VoidCallback onPressed,
  }) = _CardDataPersonalArea;

  const factory CardData.collectionsScreen({
    required String title,
    required VoidCallback onPressed,
    required VoidCallback onLongPressed,
    required int numOfItems,
    required Color color,
    Uint8List? backgroundImage,
  }) = _CardDataCollectionsScreen;
}
