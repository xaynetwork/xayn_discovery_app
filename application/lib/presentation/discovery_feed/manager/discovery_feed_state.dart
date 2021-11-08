import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';

part 'discovery_feed_state.freezed.dart';

@freezed
class DiscoveryFeedState with _$DiscoveryFeedState {
  const DiscoveryFeedState._();

  const factory DiscoveryFeedState({
    List<Document>? results,
    required int resultIndex,
    required bool isComplete,
    required bool isInErrorState,
  }) = _DiscoveryFeedState;

  factory DiscoveryFeedState.empty() => const DiscoveryFeedState(
        resultIndex: 0,
        isComplete: false,
        isInErrorState: false,
      );
}
