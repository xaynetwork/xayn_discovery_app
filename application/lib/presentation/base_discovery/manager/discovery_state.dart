import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/manager/base_discovery_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

part 'discovery_state.freezed.dart';

/// The state of the [BaseDiscoveryManager].
@freezed
class DiscoveryState with _$DiscoveryState {
  final SetEquality _setEquality = const SetEquality();

  const DiscoveryState._();

  const factory DiscoveryState({
    @Default(<Document>{}) Set<Document> results,
    @Default(<Document>{}) Set<Document> removedResults,
    required int cardIndex,
    required bool isComplete,
    @Default(false) bool isFullScreen,
    required bool isInErrorState,
    ExplicitDocumentFeedback? latestExplicitDocumentFeedback,
    @Default(false) bool shouldUpdateNavBar,
  }) = _DiscoveryState;

  factory DiscoveryState.initial() => const DiscoveryState(
        cardIndex: 0,
        isComplete: false,
        isInErrorState: false,
      );

  bool equals(DiscoveryState other) =>
      isFullScreen == other.isFullScreen &&
      cardIndex == other.cardIndex &&
      isComplete == other.isComplete &&
      isInErrorState == other.isInErrorState &&
      latestExplicitDocumentFeedback == other.latestExplicitDocumentFeedback &&
      _setEquality.equals(results, other.results) &&
      _setEquality.equals(removedResults, other.removedResults);
}
