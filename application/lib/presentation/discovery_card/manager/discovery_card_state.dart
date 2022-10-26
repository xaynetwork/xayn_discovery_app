import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/shader/foreground/foreground_painter.dart';
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
    ProcessedDocument? processedDocument,
    @Default(UserReaction.neutral) UserReaction explicitDocumentUserReaction,
    @Default(true) bool textIsReadable,
    @Default(ArcVariation.v0) ArcVariation arcVariation,
  }) = _DiscoveryCardState;

  // ignore: prefer_const_constructors
  factory DiscoveryCardState.initial() => DiscoveryCardState();

  factory DiscoveryCardState.error() => const DiscoveryCardState();
}
