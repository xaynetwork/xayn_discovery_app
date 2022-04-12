import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

abstract class ErrorNavActions {
  void openErrorScreen({String? errorCode, bool replaceCurrentRoute = true});

  void onClosePressed();
}

/// Generic error screen
class SomethingWentWrongErrorScreen extends _ErrorScreen {
  SomethingWentWrongErrorScreen({Key? key, String? errorCode})
      : super(
          key: key,
          title: R.strings.errorGenericHeaderSomethingWentWrong,
          subtitle: R.strings.errorGenericBodyPleaseTryAgainLater,
          errorCode: errorCode,
        );
}

/// This screen is to be used in scenarios where the user navigated to a
/// different page of the app, and while loading it we got an error, so there’s
/// nothing to be shown behind the error modal.
///
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    this.errorCode,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String? errorCode;

  @override
  Widget build(BuildContext context) {
    final header = Text(
      title,
      style: R.styles.lBoldStyle,
    );

    final subHeader = Text(subtitle);

    final errorCodeWidget = Text(
      '(Error: ${errorCode ?? ''})',
      style: R.styles.sStyle.copyWith(
        color: R.colors.secondaryText,
      ),
    );

    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          header,
          SizedBox(height: R.dimen.unit),
          subHeader,
          if (errorCode != null) ...[
            SizedBox(height: R.dimen.unit),
            errorCodeWidget,
          ],
        ],
      ),
    );

    final closeButton = AppGhostButton.text(
      R.strings.errorClose,
      onPressed: () => di.get<ErrorNavActions>().onClosePressed(),
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
