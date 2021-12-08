import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';

abstract class DiscoveryFeedAxisFields {
  DiscoveryFeedAxisFields._();

  static const int vertical = 0;
  static const int horizontal = 1;
}

extension DiscoveryFeedAxisToInt on DiscoveryFeedAxis {
  int toInt() {
    switch (this) {
      case DiscoveryFeedAxis.horizontal:
        return DiscoveryFeedAxisFields.horizontal;
      case DiscoveryFeedAxis.vertical:
      default:
        return DiscoveryFeedAxisFields.vertical;
    }
  }
}

extension IntToDiscoveryFeedAxis on int {
  DiscoveryFeedAxis toDiscoveryFeedAxisEnum() {
    switch (this) {
      case DiscoveryFeedAxisFields.horizontal:
        return DiscoveryFeedAxis.horizontal;
      case DiscoveryFeedAxisFields.vertical:
      default:
        return DiscoveryFeedAxis.vertical;
    }
  }
}
