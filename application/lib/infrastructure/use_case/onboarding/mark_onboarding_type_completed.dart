import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class MarkOnboardingTypeCompletedUseCase extends UseCase<OnboardingType, None> {
  final AppStatusRepository _repository;

  MarkOnboardingTypeCompletedUseCase(
    this._repository,
  );

  @override
  Stream<None> transaction(OnboardingType param) async* {
    final appStatus = _repository.appStatus;
    OnboardingStatus status = appStatus.onboardingStatus;

    switch (param) {
      case OnboardingType.homeVerticalSwipe:
        status = status.copyWith(homeVerticalSwipeDone: true);
        break;
      case OnboardingType.homeHorizontalSwipe:
        status = status.copyWith(homeSideSwipeDone: true);
        break;
      case OnboardingType.homeBookmarksManage:
        status = status.copyWith(homeManageBookmarksDone: true);
        break;
      case OnboardingType.collectionsManage:
      case OnboardingType.bookmarksManage:
        status = status.copyWith(collectionsManageDone: true);
        break;
    }
    if (status != appStatus.onboardingStatus) {
      _repository.save(appStatus.copyWith(onboardingStatus: status));
    }
    yield none;
  }
}
