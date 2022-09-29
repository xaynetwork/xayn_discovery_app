import 'package:async/async.dart' show StreamGroup;
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/topic/can_display_topic_use_case.dart';

const int _kNumOfSessionsThreshold = 1;
const int _kNumOfScrollsExistingUserThreshold = 3;
const int _kNumOfScrollsNewUserThreshold = 0;

@injectable
class ListenTopicsStatusUseCase extends UseCase<None, TopicsConditionsStatus> {
  final UserInteractionsRepository userInteractionsRepository;
  final AppStatusRepository appStatusRepository;
  final CanDisplayTopicsUseCase canDisplayTopicsUseCase;

  ListenTopicsStatusUseCase(
    this.userInteractionsRepository,
    this.appStatusRepository,
    this.canDisplayTopicsUseCase,
  );

  @override
  Stream<TopicsConditionsStatus> transaction(None param) async* {
    final canDisplay = await canDisplayTopicsUseCase.singleOutput(none);
    if (!canDisplay) {
      yield TopicsConditionsStatus.notReached;
      return;
    }

    yield* StreamGroup.merge([
      userInteractionsRepository.watch(),
      appStatusRepository.watch(),
    ]).map(
      (_) {
        final appStatus = appStatusRepository.appStatus;
        final userInteractions = userInteractionsRepository.userInteractions;
        final numberOfSessions = appStatus.numberOfSessions;
        return performTopicConditionsStatusCheck(
          numberOfSessions: numberOfSessions,
          userInteractions: userInteractions,
        );
      },
    );
  }

  @visibleForTesting
  TopicsConditionsStatus performTopicConditionsStatusCheck({
    required UserInteractions userInteractions,
    required int numberOfSessions,
  }) {
    // The conditions are listed in the description of the following task
    // https://xainag.atlassian.net/browse/TB-4050
    final numberOfScrolls = userInteractions.numberOfScrollsPerSession;
    if (numberOfSessions <= _kNumOfSessionsThreshold) {
      if (numberOfScrolls >= _kNumOfScrollsNewUserThreshold) {
        return TopicsConditionsStatus.reached;
      }
    } else {
      if (numberOfScrolls >= _kNumOfScrollsExistingUserThreshold) {
        return TopicsConditionsStatus.reached;
      }
    }
    return TopicsConditionsStatus.notReached;
  }
}

enum TopicsConditionsStatus { notReached, reached }
