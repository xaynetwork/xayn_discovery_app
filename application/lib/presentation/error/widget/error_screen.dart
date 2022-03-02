import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_mixin.dart';

/// This screen is to be used in scenarios where the user navigated to a
/// different page of the app, and while loading it we got an error, so there’s
/// nothing to be shown behind the error modal.
///
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final header = Text(R.strings.errorGenericHeaderSomethingWentWrong,
        style: R.styles.lBoldStyle);

    final subHeader = Text(R.strings.errorGenericBodyPleaseTryAgainLater);

    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          header,
          SizedBox(height: R.dimen.unit),
          subHeader,
        ],
      ),
    );

    final closeButton = AppGhostButton.text(
      R.strings.errorClose,
      onPressed: di.get<ErrorNavActions>().onClosePressed,
      backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: body),
        closeButton,
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(R.dimen.unit3),
          child: column,
        ),
      ),
    );
  }
}
