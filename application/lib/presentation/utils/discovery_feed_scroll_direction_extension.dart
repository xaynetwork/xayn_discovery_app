import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';

extension DiscoveryFeedAxisExtension on DiscoveryFeedAxis {
  Axis get axis {
    switch (this) {
      case DiscoveryFeedAxis.vertical:
        return Axis.vertical;
      case DiscoveryFeedAxis.horizontal:
        return Axis.horizontal;
    }
  }
}
