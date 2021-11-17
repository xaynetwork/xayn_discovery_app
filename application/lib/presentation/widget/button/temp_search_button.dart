import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// A temporary widget which displays a search icon.
/// Should be removed once the bottom navigation is ready.
class TempSearchButton extends StatelessWidget {
  const TempSearchButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: SvgPicture.asset(
        R.assets.icons.search,
        color: R.colors.iconBackground,
      ),
    );
  }
}
