import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_toolbar_icon_model.freezed.dart';

@freezed
class AppToolbarIconModel with _$AppToolbarIconModel {
  factory AppToolbarIconModel({
    required String iconPath,
    required VoidCallback onPressed,
    Key? iconKey,
  }) = _AppToolbarIconModel;
}
