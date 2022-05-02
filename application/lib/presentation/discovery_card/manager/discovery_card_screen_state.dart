import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/models/document.dart';

part 'discovery_card_screen_state.freezed.dart';

@freezed
class DiscoveryCardScreenState with _$DiscoveryCardScreenState {
  factory DiscoveryCardScreenState.initial() = _DiscoveryCardScreenStateInitial;

  factory DiscoveryCardScreenState.populated({
    required Document document,
  }) = _DiscoveryCardScreenStatePopulated;
}
