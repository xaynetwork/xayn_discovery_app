import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_toolbar_data.freezed.dart';

@freezed
class AppToolbarData with _$AppToolbarData {
  const factory AppToolbarData.titleOnly({
    required String yourTitle,
  }) = _AppToolbarDataTitleOnly;

  const factory AppToolbarData.withTrailingIcon({
    required String yourTitle,
    required String iconPath,
    VoidCallback? onPressed,
  }) = _AppToolbarDataWithTrailingIcon;
}
