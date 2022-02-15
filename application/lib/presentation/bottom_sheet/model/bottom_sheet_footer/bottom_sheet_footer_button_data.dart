import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bottom_sheet_footer_button_data.freezed.dart';

@freezed
class BottomSheetFooterButton with _$BottomSheetFooterButton {
  factory BottomSheetFooterButton({
    required String text,
    required VoidCallback onPressed,
    @Default(false) bool isDisabled,
  }) = _BottomSheetFooterButton;
}
