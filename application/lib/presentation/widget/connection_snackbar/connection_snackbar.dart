import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ConnectionSnackBar extends StatelessWidget {
  ConnectionSnackBar({Key? key}) : super(key: key);

  late final ConnectivityObserver connectivityObserver = di.get();
  @override
  Widget build(BuildContext context) => Container(
        color: R.colors.connectionErrorBackground,
        height: R.dimen.connectionErrorWidgetHeight,
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: R.styles.connectionErrorMessageTextStyle,
          child: Text(R.strings.noInternetConnection),
        ),
      );
}
