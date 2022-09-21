import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';

const int _kNumOfSessionsThreshold = 2;
const int _kNumOfScrollsThreshold = 5;

@injectable
class ListenPushNotificationsConditionsStatusUseCase
    extends UseCase<None, PushNotificationsConditionsStatus> {
  final UserInteractionsRepository userInteractionsRepository;
  final AppStatusRepository appStatusRepository;

  ListenPushNotificationsConditionsStatusUseCase(
    this.userInteractionsRepository,
    this.appStatusRepository,
  );

  @override
  Stream<PushNotificationsConditionsStatus> transaction(None param) {
    return userInteractionsRepository.watch().map(
      (_) {
        final numberOfSessions = appStatusRepository.appStatus.numberOfSessions;
        final userInteractions = userInteractionsRepository.userInteractions;

        return performPushNotificationsConditionsStatusCheck(
          numberOfSessions: numberOfSessions,
          userInteractions: userInteractions,
        );
      },
    );
  }

  @visibleForTesting
  PushNotificationsConditionsStatus
      performPushNotificationsConditionsStatusCheck({
    required int numberOfSessions,
    required UserInteractions userInteractions,
  }) {
    // The conditions are listed in the description of the following story
    // https://xainag.atlassian.net/browse/TB-4088
    final reached = numberOfSessions >= _kNumOfSessionsThreshold &&
        userInteractions.numberOfScrollsPerSession >= _kNumOfScrollsThreshold;
    return reached
        ? PushNotificationsConditionsStatus.reached
        : PushNotificationsConditionsStatus.notReached;
  }
}

enum PushNotificationsConditionsStatus { notReached, reached }
