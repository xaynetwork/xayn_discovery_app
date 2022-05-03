import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/manager/app_scaffold_manager.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/manager/app_scaffold_state.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_additional_widget_data.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_app/presentation/widget/connection_snackbar/connection_snackbar.dart';

/// Custom version of the Scaffold introduced for handling
/// the displaying of the error message when connection is down
/// To be used for every screen
class AppScaffold extends StatelessWidget {
  final Widget body;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final AppToolbarData? appToolbarData;

  late final AppScaffoldManager _appScaffoldManager = di.get();
  AppScaffold({
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.appToolbarData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppScaffoldManager, AppScaffoldState>(
        bloc: _appScaffoldManager,
        builder: (_, state) =>
            state.connectivityResult != ConnectivityResult.none
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
              child: const ConnectionSnackBar(),
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
                  widget: const ConnectionSnackBar(),
                  widgetHeight: R.dimen.collectionItemBottomSheetHeight,
                ),
              )
            : null,
      );
}
