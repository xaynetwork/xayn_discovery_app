import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// Provides standard animation for switching between screen states
class ScreenStateSwitcher extends StatelessWidget {
  final Widget child;

  const ScreenStateSwitcher({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: R.animations.screenStateChangeDuration,
        child: child,
      );
}
