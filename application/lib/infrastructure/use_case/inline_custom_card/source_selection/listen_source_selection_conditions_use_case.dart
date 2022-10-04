import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/inline_card_utils.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/can_display_source_selection_use_case.dart';

const int _kNumOfSessionsThreshold = 1;
const int _kNumOfScrollsThreshold = 5;
const int _kNumberOfSourcesTrustedThreshold = 0;

@injectable
class ListenSourceConditionsStatusUseCase
    extends UseCase<None, SourceSelectionConditionsStatus> {
  final UserInteractionsRepository userInteractionsRepository;
  final AppStatusRepository appStatusRepository;
  final CanDisplaySourceSelectionUseCase canDisplaySourceSelectionUseCase;

  ListenSourceConditionsStatusUseCase(
    this.userInteractionsRepository,
    this.appStatusRepository,
    this.canDisplaySourceSelectionUseCase,
  );

  @override
  Stream<SourceSelectionConditionsStatus> transaction(None param) async* {
    final canDisplay =
        await canDisplaySourceSelectionUseCase.singleOutput(none);
    if (!canDisplay) {
      yield SourceSelectionConditionsStatus.notReached;
      return;
    }

    yield* userInteractionsRepository.watch().map(
      (_) {
        final appStatus = appStatusRepository.appStatus;
        final userInteractions = userInteractionsRepository.userInteractions;
        final numberOfSessions = appStatus.numberOfSessions;

        return performSourceSelectionConditionsStatusCheck(
          numberOfSessions: numberOfSessions,
          userInteractions: userInteractions,
        );
      },
    );
  }

  @visibleForTesting
  SourceSelectionConditionsStatus performSourceSelectionConditionsStatusCheck({
    required UserInteractions userInteractions,
    required int numberOfSessions,
  }) {
    // The conditions are listed in the description of the following task
    // https://xainag.atlassian.net/browse/TB-4049
    if (numberOfSessions <= _kNumOfSessionsThreshold) {
      final numberOfScrolls = userInteractions.numberOfScrollsPerSession;
      final numberOfSourcesTrusted = userInteractions.numberOfSourcesTrusted;
      final hasExceededSwipeCount = InLineCardUtils.hasExceededSwipeCount(
          numberOfScrolls, _kNumOfScrollsThreshold);

      if (hasExceededSwipeCount &&
          numberOfSourcesTrusted <= _kNumberOfSourcesTrustedThreshold) {
        return SourceSelectionConditionsStatus.reached;
      }
    }
    return SourceSelectionConditionsStatus.notReached;
  }
}

enum SourceSelectionConditionsStatus { notReached, reached }
