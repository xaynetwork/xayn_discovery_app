import 'package:freezed_annotation/freezed_annotation.dart';

import 'bottom_sheet_footer_button_data.dart';

part 'bottom_sheet_footer_data.freezed.dart';

@freezed
class BottomSheetFooterSetup with _$BottomSheetFooterSetup {
  const factory BottomSheetFooterSetup.row({
    required BottomSheetFooterButton buttonData,
  }) = _BottomSheetFooterSetupTwoButtons;

  const factory BottomSheetFooterSetup.column({
    required List<BottomSheetFooterButton> buttonsData,
  }) = _BottomSheetFooterSetupThreeButtons;
}
