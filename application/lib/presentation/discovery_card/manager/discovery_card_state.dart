import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'discovery_card_state.freezed.dart';

/// Represents the state of the [DiscoveryCardManager].
@freezed
class DiscoveryCardState with _$DiscoveryCardState {
  const DiscoveryCardState._();

  const factory DiscoveryCardState({
    @Default(false) bool isComplete,
    @Default(false) bool isBookmarked,

    /// Since a special snackbar shows only when the bookmark icon is toggled,
    /// we use this variable to detect if the isBookmarked change was due to the
    /// button toggling and was not originated from long pressing the bookmark icon.
    @Default(false) bool isBookmarkToggled,
    Object? error,
    ProcessedDocument? processedDocument,
    @Default(UserReaction.neutral) UserReaction explicitDocumentUserReaction,
  }) = _DiscoveryCardState;

  factory DiscoveryCardState.initial() => const DiscoveryCardState();

  factory DiscoveryCardState.error(Object? error) => DiscoveryCardState(
        error: error,
      );
}

extension DiscoveryCardStateExtension on DiscoveryCardState {
  bool get hasError => error != null;
}
