import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/model/app_toolbar_icon_model.dart';

part 'app_toolbar_data.freezed.dart';

@freezed
class AppToolbarData with _$AppToolbarData {
  const factory AppToolbarData.titleOnly({
    required String title,
  }) = _AppToolbarDataTitleOnly;

  const factory AppToolbarData.withTrailingIcon({
    required String title,
    required String iconPath,
    VoidCallback? onPressed,
    Key? iconkey,
  }) = _AppToolbarDataWithTrailingIcon;

  const factory AppToolbarData.withTwoTrailingIcons({
    @Assert('iconModels.length == 2', 'a list with two AppToolbarIconModel must be passed')
        required List<AppToolbarIconModel> iconModels,
    required String title,
  }) = _AppToolbarDataWithTwoTrailingIcons;
}
