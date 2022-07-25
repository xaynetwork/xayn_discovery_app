import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as engine;

/// Internal representation of [engine.FeedMarket]
/// that we store in [FeedSettingsRepository]
class InternalFeedMarket extends Equatable {
  final String countryCode;
  final String languageCode;

  const InternalFeedMarket({
    required this.countryCode,
    required this.languageCode,
  });

  @override
  List<Object> get props => [
        countryCode,
        languageCode,
      ];
}
