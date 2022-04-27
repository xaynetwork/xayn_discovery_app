import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@singleton
class OnboardingStatusToDbEntityMapMapper
    extends Mapper<OnboardingStatus, DbEntityMap> {
  const OnboardingStatusToDbEntityMapMapper();

  @override
  DbEntityMap map(OnboardingStatus input) => {
        OnboardingStatusFields.homeVerticalSwipeDone:
            input.homeVerticalSwipeDone,
        OnboardingStatusFields.homeSideSwipeDone: input.homeSideSwipeDone,
        OnboardingStatusFields.homeManageBookmarksDone:
            input.homeManageBookmarksDone,
        OnboardingStatusFields.collectionsManageDone:
            input.collectionsManageDone,
      };
}

@singleton
class DbEntityMapToOnboardingStatusMapper
    extends Mapper<DbEntityMap?, OnboardingStatus> {
  const DbEntityMapToOnboardingStatusMapper();

  @override
  OnboardingStatus map(Map? input) {
    if (input == null) return const OnboardingStatus.initial();

    final homeVerticalSwipeDone =
        input[OnboardingStatusFields.homeVerticalSwipeDone] ??
            defaultHomeVerticalSwipe;
    final homeSideSwipeDone = input[OnboardingStatusFields.homeSideSwipeDone] ??
        defaultHomeSideSwipeDone;
    final homeManageBookmarksDone =
        input[OnboardingStatusFields.homeManageBookmarksDone] ??
            defaultHomeManageBookmarksDone;
    final collectionsManageDone =
        input[OnboardingStatusFields.collectionsManageDone] ??
            defaultCollectionsManageDone;

    return OnboardingStatus(
      homeVerticalSwipeDone: homeVerticalSwipeDone,
      homeSideSwipeDone: homeSideSwipeDone,
      homeManageBookmarksDone: homeManageBookmarksDone,
      collectionsManageDone: collectionsManageDone,
    );
  }
}

abstract class OnboardingStatusFields {
  OnboardingStatusFields._();

  static const homeVerticalSwipeDone = 0;
  static const homeSideSwipeDone = 1;
  static const homeManageBookmarksDone = 2;
  static const collectionsManageDone = 3;
}
