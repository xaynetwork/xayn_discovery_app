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

  group('IntToDiscoveryFeedAxisMapper tests: ', () {
    test('0 maps to DiscoveryFeedAxis.vertical', () {
      final value = intToDiscoveryFeedAxisMapper.map(0);
      expect(value, DiscoveryFeedAxis.vertical);
    });

    test('1 maps to DiscoveryFeedAxis.horizontal', () {
      final value = intToDiscoveryFeedAxisMapper.map(1);
      expect(value, DiscoveryFeedAxis.horizontal);
    });

    test('2 maps to DiscoveryFeedAxis.vertical', () {
      final value = intToDiscoveryFeedAxisMapper.map(2);
      expect(value, DiscoveryFeedAxis.vertical);
    });

    test('null maps to DiscoveryFeedAxis.vertical', () {
      final value = intToDiscoveryFeedAxisMapper.map(null);
      expect(value, DiscoveryFeedAxis.vertical);
    });
  });

  group('DiscoveryFeedAxisToIntMapper tests: ', () {
    test('DiscoveryFeedAxis.vertical maps to 0', () {
      final value =
          discoveryFeedAxisToIntMapper.map(DiscoveryFeedAxis.vertical);
      expect(value, 0);
    });

    test('DiscoveryFeedAxis.horizontal maps to 1', () {
      final value =
          discoveryFeedAxisToIntMapper.map(DiscoveryFeedAxis.horizontal);
      expect(value, 1);
    });
  });
}
