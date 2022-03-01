import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/error/widget/error_bottom_sheet.dart';

abstract class ErrorNavActions {
  void openErrorScreen();

  void onClosePressed();
}

mixin ErrorHandlingMixin {
  void openErrorScreen() => di.get<ErrorNavActions>().openErrorScreen();

  void showErrorBottomSheet(BuildContext context) => showAppBottomSheet(
        context,
        builder: (_) => const ErrorBottomSheet(),
      );
}
