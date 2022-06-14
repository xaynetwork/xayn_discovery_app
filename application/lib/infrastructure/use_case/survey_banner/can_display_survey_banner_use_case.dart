import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/survey_banner/survey_banner.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

@injectable
class CanDisplaySurveyBannerUseCase extends UseCase<None, bool> {
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final AppStatusRepository _appStatusRepository;
  final FeatureManager _featureManager;

  CanDisplaySurveyBannerUseCase(
    this._getSubscriptionStatusUseCase,
    this._appStatusRepository,
    this._featureManager,
  );

  @override
  Stream<bool> transaction(None param) async* {
    if (!_featureManager.isPromptSurveyEnabled) {
      yield false;
      return;
    }

    final subscriptionStatus =
        await _getSubscriptionStatusUseCase.singleOutput(none);

    final appStatus = _appStatusRepository.appStatus;

    final canBeShown = subscriptionStatus.isSubscriptionActive
        ? performCheckForSubcribedUser(appStatus)
        : performCheckForNotSubscribedUser(appStatus.cta.surveyBanner);

    yield canBeShown;
  }

  bool performCheckForSubcribedUser(
    AppStatus appStatus,
  ) {
    final surveyBanner = appStatus.cta.surveyBanner;
    final numOfTimesSurveyBannerHasBeenShown = surveyBanner.numberOfTimesShown;
    final hasSurveyBannerBeenClicked = surveyBanner.hasSurveyBannerBeenClicked;
    final lastSessionNumberWhenSurveyShown =
        surveyBanner.lastSessionNumberWhenShown;
    final currentSessionNumber = appStatus.numberOfSessions;

    // The conditions are listed in the description of the following task
    // https://xainag.atlassian.net/browse/TB-3809

    // for subscribers, we show them up to 2x
    if (numOfTimesSurveyBannerHasBeenShown >= 2) return false;

    // if they click on the CTA to go to the survey the first time they see it, we do not show it to them again
    if (hasSurveyBannerBeenClicked) return false;

    // if they did not click on the CTA the first time, we show it to them a second time 2 sessions after they saw it the first time
    final isSessionDeltaTresholdReached =
        currentSessionNumber - lastSessionNumberWhenSurveyShown >= 2;

    if (!hasSurveyBannerBeenClicked && !isSessionDeltaTresholdReached) {
      return false;
    }

    return true;
  }

  bool performCheckForNotSubscribedUser(SurveyBanner surveyBanner) =>
      // for non-subscribers, we only show the banner to them 1x
      surveyBanner.numberOfTimesShown == 0;
}
