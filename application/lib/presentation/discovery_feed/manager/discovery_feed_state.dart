import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

part 'discovery_feed_state.freezed.dart';

/// The state of the [DiscoveryFeedManager].
@freezed
class DiscoveryFeedState with _$DiscoveryFeedState {
  const DiscoveryFeedState._();

  const factory DiscoveryFeedState({
    @Default(<Document>{}) Set<Document> results,
    required int cardIndex,
    required bool isComplete,
    @Default(false) bool isFullScreen,
    required bool isInErrorState,
  }) = _DiscoveryFeedState;

  factory DiscoveryFeedState.initial() => const DiscoveryFeedState(
        cardIndex: 0,
        isComplete: false,
        isInErrorState: false,
      );

  bool equals(DiscoveryFeedState other) =>
      isFullScreen == other.isFullScreen &&
      cardIndex == other.cardIndex &&
      isComplete == other.isComplete &&
      isInErrorState == other.isInErrorState &&
      const SetEquality().equals(results, other.results);
}
