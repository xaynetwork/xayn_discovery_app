import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';

part 'discovery_state.freezed.dart';

/// The state of the [BaseDiscoveryManager].
@freezed
class DiscoveryState with _$DiscoveryState {
  const DiscoveryState._();

  const factory DiscoveryState({
    @Default(<Card>{}) Set<Card> cards,
    required int cardIndex,
    required bool isComplete,
    @Default(false) bool isFullScreen,
    ExplicitDocumentFeedback? latestExplicitDocumentFeedback,
    @Default(false) bool shouldUpdateNavBar,
    required bool didReachEnd,
    SubscriptionStatus? subscriptionStatus,
    ReaderModeBackgroundColor? readerModeBackgroundColor,
  }) = _DiscoveryState;

  factory DiscoveryState.initial() => const DiscoveryState(
        cardIndex: 0,
        isComplete: false,
        didReachEnd: false,
      );

  bool equals(DiscoveryState other) =>
      isFullScreen == other.isFullScreen &&
      cardIndex == other.cardIndex &&
      isComplete == other.isComplete &&
      didReachEnd == other.didReachEnd &&
      latestExplicitDocumentFeedback == other.latestExplicitDocumentFeedback &&
      subscriptionStatus == other.subscriptionStatus &&
      readerModeBackgroundColor == other.readerModeBackgroundColor;
}
