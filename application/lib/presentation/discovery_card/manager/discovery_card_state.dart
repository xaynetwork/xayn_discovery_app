import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';

part 'discovery_card_state.freezed.dart';

/// Represents the state of the [DiscoveryCardManager].
@freezed
class DiscoveryCardState with _$DiscoveryCardState {
  const DiscoveryCardState._();

  const factory DiscoveryCardState({
    @Default(false) bool isComplete,
    ProcessedDocument? output,
  }) = _DiscoveryCardState;

  factory DiscoveryCardState.initial() => const DiscoveryCardState();

  factory DiscoveryCardState.error() => const DiscoveryCardState();
}
