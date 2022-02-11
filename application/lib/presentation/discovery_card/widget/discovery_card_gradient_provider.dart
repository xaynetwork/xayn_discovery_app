import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

mixin DiscoveryCardGradientProvider {
  Gradient buildGradient() => LinearGradient(
        colors: [
          R.colors.swipeCardBackground.withAlpha(120),
          R.colors.swipeCardBackground.withAlpha(40),
          R.colors.swipeCardBackground.withAlpha(255),
          R.colors.swipeCardBackground.withAlpha(255),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 0.15, 0.8, 1],
      );
}
