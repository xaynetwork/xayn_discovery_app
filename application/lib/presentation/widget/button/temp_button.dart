import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// A temporary widget used for navigation.
/// Should be removed once the bottom navigation is ready.
class TempButton extends StatelessWidget {
  const TempButton({
    Key? key,
    required this.iconName,
    required this.onPressed,
  }) : super(key: key);

  final String iconName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: SvgPicture.asset(
        iconName,
        color: R.colors.iconBackground,
      ),
    );
  }
}
