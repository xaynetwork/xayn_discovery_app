import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class BottomSheetClickableOption extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const BottomSheetClickableOption({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        child: child,
        height: R.dimen.unit6,
      ),
    );
  }
}
