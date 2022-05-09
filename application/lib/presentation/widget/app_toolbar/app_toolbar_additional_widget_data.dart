import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_toolbar_additional_widget_data.freezed.dart';

/// Object containing data for showing an additional widget above
/// the toolbar. Used in the [AppToolbar] widget
@freezed
class AppToolbarAdditionalWidgetData with _$AppToolbarAdditionalWidgetData {
  const factory AppToolbarAdditionalWidgetData({
    required Widget widget,
    required double widgetHeight,
  }) = _AppToolbarAdditionalWidgetData;
}
