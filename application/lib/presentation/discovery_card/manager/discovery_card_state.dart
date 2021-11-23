import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_readability/xayn_readability.dart';

part 'discovery_card_state.freezed.dart';

/// Represents the state of the [DiscoveryCardManager].
@freezed
class DiscoveryCardState with _$DiscoveryCardState {
  const DiscoveryCardState._();

  const factory DiscoveryCardState({
    @Default(false) bool isComplete,
    @Default(false) bool isInReaderMode,
    ProcessHtmlResult? result,
    @Default([]) List<String> paragraphs,
    @Default([]) List<String> images,
    PaletteGenerator? paletteGenerator,
  }) = _DiscoveryCardState;

  factory DiscoveryCardState.initial() => const DiscoveryCardState();

  factory DiscoveryCardState.error() => const DiscoveryCardState();
}
