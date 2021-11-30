import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_scroll_direction.dart';

extension Utils on DiscoveryFeedScrollDirection {
  Axis get axis {
    switch (this) {
      case DiscoveryFeedScrollDirection.vertical:
        return Axis.vertical;
      case DiscoveryFeedScrollDirection.horizontal:
        return Axis.horizontal;
    }
  }
}
