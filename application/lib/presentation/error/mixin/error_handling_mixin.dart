import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/utils/tooltip_utils.dart';

abstract class ErrorNavActions {
  void openErrorScreen();

  void onClosePressed();
}

mixin ErrorHandlingMixin {
  void openErrorScreen() => di.get<ErrorNavActions>().openErrorScreen();

  void showErrorBottomSheet(BuildContext context) => showAppBottomSheet(
        context,
        builder: (_) => const ErrorBottomSheet(),
        allowStacking: false,
      );

  void handleError(
    BuildContext context,
    ErrorObject error, [
    Function(TooltipKey)? showTooltip,
  ]) {
    if (!error.hasError) return;

    if (showTooltip == null) {
      showErrorBottomSheet(context);
      return;
    }

    TooltipKey? key = TooltipUtils.getErrorKey(error.errorObject);

    if (key == null) {
      showErrorBottomSheet(context);
      return;
    }

    showTooltip(key);
  }
}
