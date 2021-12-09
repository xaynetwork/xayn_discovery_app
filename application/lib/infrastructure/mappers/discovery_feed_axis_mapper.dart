import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const int _vertical = 0;
const int _horizontal = 1;

@singleton
class IntToDiscoveryFeedAxisMapper implements Mapper<int?, DiscoveryFeedAxis> {
  const IntToDiscoveryFeedAxisMapper();

  @override
  DiscoveryFeedAxis map(int? input) {
    switch (input) {
      case _vertical:
        return DiscoveryFeedAxis.vertical;
      case _horizontal:
      default:
        return DiscoveryFeedAxis.horizontal;
    }
  }
}

@singleton
class DiscoveryFeedAxisToIntMapper implements Mapper<DiscoveryFeedAxis, int> {
  const DiscoveryFeedAxisToIntMapper();

  @override
  int map(DiscoveryFeedAxis input) {
    switch (input) {
      case DiscoveryFeedAxis.horizontal:
        return _horizontal;
      case DiscoveryFeedAxis.vertical:
      default:
        return _vertical;
    }
  }
}
