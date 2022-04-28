import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_additional_widget_data.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/connection_snackbar/connection_snackbar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final AppToolbarData? appToolbarData;

  late final ConnectivityObserver connectivityObserver = di.get();
  AppScaffold({
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.appToolbarData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: connectivityObserver.onConnectivityChanged,
        builder: (_, snapshot) => snapshot.data != ConnectivityResult.none
            ? _buildScaffolWithoutErrorMessage()
            : appToolbarData == null
                ? _buildBaseScaffoldWithErrorMessage(
                    MediaQuery.of(context).padding.top)
                : _buildScaffoldWithToolBarAndErrorMessage(
                    MediaQuery.of(context).padding.top),
      );

  Widget _buildScaffolWithoutErrorMessage() => Scaffold(
        body: body,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: backgroundColor,
        appBar: appToolbarData != null
            ? AppToolbar(appToolbarData: appToolbarData!)
            : null,
      );

  Widget _buildBaseScaffoldWithErrorMessage(double topPadding) => Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: R.dimen.connectionErrorWidgetHeight),
              child: body,
            ),
            Positioned(
              top: topPadding,
              right: 0.0,
              left: 0.0,
              child: ConnectionSnackBar(),
            ),
          ],
        ),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: backgroundColor,
      );

  Widget _buildScaffoldWithToolBarAndErrorMessage(double topPadding) =>
      Scaffold(
        body: body,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: backgroundColor,
        appBar: appToolbarData != null
            ? AppToolbar(
                appToolbarData: appToolbarData!,
                additionalWidgetData: AppToolbarAdditionalWidgetData(
                  widget: ConnectionSnackBar(),
                  widgetHeight: R.dimen.collectionItemBottomSheetHeight,
                ),
              )
            : null,
      );
}
