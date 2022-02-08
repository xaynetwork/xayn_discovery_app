import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'discovery_card_screen_state.freezed.dart';

@freezed
class DiscoveryCardScreenState with _$DiscoveryCardScreenState {
  factory DiscoveryCardScreenState.initial() = _DiscoveryCardScreenStateInitial;

  factory DiscoveryCardScreenState.populated({
    required Document document,
  }) = _DiscoveryCardScreenStatePopulated;
}
