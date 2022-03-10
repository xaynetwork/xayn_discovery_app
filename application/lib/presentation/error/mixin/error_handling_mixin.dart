import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/tooltip_utils.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';

mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  void openErrorScreen() => di.get<ErrorNavActions>().openErrorScreen();

  void showErrorBottomSheet({bool allowStacking = false}) => showAppBottomSheet(
        context,
        builder: (_) => const ErrorBottomSheet(),
        allowStacking: allowStacking,
      );

  void handleError(
    ErrorObject error, [
    OnToolTipError? showTooltip,
  ]) {
    if (!error.hasError) return;

    if (showTooltip == null) {
      showErrorBottomSheet();
      return;
    }

    TooltipKey? key = TooltipUtils.getErrorKey(error.errorObject);

    if (key == null) {
      showErrorBottomSheet();
      return;
    }

    showTooltip(key);
  }
}
