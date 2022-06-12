import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';

const int _kNumOfSessionsThreshold = 2;
const int _kNumOfScrollsThreshold = 5;
const int _kNumOfInteractionsThreshold = 10;

@injectable
class ListenSurveyConditionsStatusUseCase
    extends UseCase<None, SurveyConditionsStatus> {
  final UserInteractionsRepository userInteractionsRepository;
  final AppStatusRepository appStatusRepository;

  ListenSurveyConditionsStatusUseCase(
    this.userInteractionsRepository,
    this.appStatusRepository,
  );

  @override
  Stream<SurveyConditionsStatus> transaction(None param) async* {
    yield* userInteractionsRepository.watch().map(
      (_) {
        final numberOfSessions = appStatusRepository.appStatus.numberOfSessions;
        final userInteractions = userInteractionsRepository.userInteractions;

        return performSurveyConditionsStatusCheck(
          numberOfSessions: numberOfSessions,
          userInteractions: userInteractions,
        );
      },
    );
  }

  @visibleForTesting
  SurveyConditionsStatus performSurveyConditionsStatusCheck({
    required int numberOfSessions,
    required UserInteractions userInteractions,
  }) {
    // The conditions are listed in the description of the following task
    // https://xainag.atlassian.net/browse/TB-3809
    if (numberOfSessions >= _kNumOfSessionsThreshold) {
      final numberOfScrolls = userInteractions.numberOfScrolls;
      final numberOfInteractions = userInteractions.totalNumberOfInteractions;

      if (numberOfInteractions >= _kNumOfInteractionsThreshold &&
          numberOfScrolls >= _kNumOfScrollsThreshold &&
          numberOfScrolls < numberOfInteractions) {
        return SurveyConditionsStatus.reached;
      }
    }
    return SurveyConditionsStatus.notReached;
  }
}

enum SurveyConditionsStatus { notReached, reached }
