import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';

/// The urls are listed in the description of the following task
/// https://xainag.atlassian.net/browse/TB-3785
const String notSubscribedUserSurveyUrl = 'https://xayn.com/research/nosu_01/';
const String subscribedUserSurveyUrl = 'https://xayn.com/research/subs_01/';

@injectable
class HandleSurveyBannerClickedUseCase extends UseCase<None, None> {
  final AppStatusRepository appStatusRepository;
  final UrlOpener urlOpener;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;

  HandleSurveyBannerClickedUseCase(
    this.appStatusRepository,
    this.urlOpener,
    this._getSubscriptionStatusUseCase,
  );

  @override
  Stream<None> transaction(None param) async* {
    /// Get the current status of the data
    final appStatus = appStatusRepository.appStatus;
    final cta = appStatus.cta;
    final surveyBanner = cta.surveyBanner;

    /// Update the status of the data
    final updatedCta = cta.copyWith(
      surveyBanner: surveyBanner.clicked(
        sessionNumber: appStatus.numberOfSessions,
      ),
    );
    final updatedAppStatus = appStatus.copyWith(cta: updatedCta);
    appStatusRepository.save(updatedAppStatus);

    final subscriptionStatus =
        await _getSubscriptionStatusUseCase.singleOutput(none);

    subscriptionStatus.isSubscriptionActive
        ? urlOpener.openUrl(subscribedUserSurveyUrl)
        : urlOpener.openUrl(notSubscribedUserSurveyUrl);

    yield none;
  }
}
