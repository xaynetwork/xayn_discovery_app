import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/tooltip_utils.dart';

mixin ErrorHandlingManagerMixin<T> on OverlayManagerMixin<T> {
  void openErrorScreen() => di.get<ErrorNavActions>().openErrorScreen();

  void showErrorBottomSheet({bool allowStacking = false}) => showOverlay(
      OverlayData.bottomSheetGenericError(allowStacking: allowStacking));

  void handleError(
    Object? error, {
    bool showTooltip = true,
  }) {
    if (error is ErrorObject && !error.hasError || error == null) return;

    if (!showTooltip) {
      showErrorBottomSheet();
      return;
    }

    final data = TooltipUtils.getErrorData(
        error is ErrorObject ? error.errorObject : error);

    if (data == null) {
      showErrorBottomSheet();
      return;
    }

    showOverlay(OverlayData.tooltipError(data));
  }
}
