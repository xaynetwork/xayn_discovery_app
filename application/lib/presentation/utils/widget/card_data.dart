import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';

part 'card_data.freezed.dart';

@freezed
class CardData with _$CardData {
  const factory CardData.personalArea({
    required Key key,
    required String title,
    required Color color,
    required String svgIconPath,
    required String svgBackgroundPath,
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
    DocumentProvider? provider,
    Uint8List? backgroundImage,
  }) = _CardDataBookmark;
}
