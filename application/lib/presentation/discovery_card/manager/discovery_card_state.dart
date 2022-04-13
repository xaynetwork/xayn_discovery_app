import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'discovery_card_state.freezed.dart';

enum BookmarkStatus { unknown, bookmarked, notBookmarked }

/// Represents the state of the [DiscoveryCardManager].
@freezed
class DiscoveryCardState with _$DiscoveryCardState {
  const DiscoveryCardState._();

  const factory DiscoveryCardState({
    @Default(false) bool isComplete,
    @Default(BookmarkStatus.unknown) BookmarkStatus bookmarkStatus,
    @Default(ErrorObject()) ErrorObject error,
    ProcessedDocument? processedDocument,
    @Default(UserReaction.neutral) UserReaction explicitDocumentUserReaction,
  }) = _DiscoveryCardState;

  // ignore: prefer_const_constructors
  factory DiscoveryCardState.initial() => DiscoveryCardState();

  factory DiscoveryCardState.error(Object error) => DiscoveryCardState(
        error: ErrorObject(error),
      );
}
