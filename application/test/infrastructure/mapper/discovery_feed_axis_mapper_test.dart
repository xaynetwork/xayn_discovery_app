import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

void main() {
  late IntToDiscoveryFeedAxisMapper intToDiscoveryFeedAxisMapper;
  late DiscoveryFeedAxisToIntMapper discoveryFeedAxisToIntMapper;

  setUp(() async {
    intToDiscoveryFeedAxisMapper = const IntToDiscoveryFeedAxisMapper();
    discoveryFeedAxisToIntMapper = const DiscoveryFeedAxisToIntMapper();
  });

  test('IntToDiscoveryFeedAxisMapper tests', () {
    final data = <int?, DiscoveryFeedAxis>{
      0: DiscoveryFeedAxis.vertical,
      1: DiscoveryFeedAxis.horizontal,
      2: DiscoveryFeedAxis.vertical,
      666: DiscoveryFeedAxis.vertical,
      null: DiscoveryFeedAxis.vertical,
    };
    final results = <DiscoveryFeedAxis>[];
    for (final value in data.keys) {
      results.add(intToDiscoveryFeedAxisMapper.map(value));
    }
    expect(results, equals(data.values));
  });

  test('DiscoveryFeedAxisToIntMapper tests', () {
    final results = <int>[];
    for (final axis in DiscoveryFeedAxis.values) {
      results.add(discoveryFeedAxisToIntMapper.map(axis));
    }
    expect(results, [0, 1]);
  });
}
