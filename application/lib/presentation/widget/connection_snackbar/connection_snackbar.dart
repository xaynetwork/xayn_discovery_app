import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ConnectionSnackBar extends StatelessWidget {
  const ConnectionSnackBar({Key? key}) : super(key: key);

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
