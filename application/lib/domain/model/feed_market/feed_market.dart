import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart' as engine;

typedef FeedMarkets = Set<FeedMarket>;

/// Internal representation of [engine.FeedMarket]
class FeedMarket extends Equatable {
  final String countryCode;
  final String languageCode;

  const FeedMarket({
    required this.countryCode,
    required this.languageCode,
  });

  @override
  List<Object> get props => [
        countryCode,
        languageCode,
      ];
}
