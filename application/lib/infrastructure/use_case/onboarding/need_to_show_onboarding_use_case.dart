import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class NeedToShowOnboardingUseCase extends UseCase<OnboardingType, bool> {
  final AppStatusRepository _appStatusRepository;
  final CollectionsRepository _collectionsRepository;
  final BookmarksRepository _bookmarksRepository;

  NeedToShowOnboardingUseCase(
    this._appStatusRepository,
    this._collectionsRepository,
    this._bookmarksRepository,
  );

  @override
  Stream<bool> transaction(OnboardingType param) async* {
    final appStatus = _appStatusRepository.appStatus;
    switch (param) {
      case OnboardingType.homeVerticalSwipe:
        yield _showHomeVerticalSwipe(appStatus);
        break;
      case OnboardingType.homeHorizontalSwipe:
        yield _showHomeSideSwipe(appStatus);
        break;
      case OnboardingType.homeBookmarksManage:
        yield _showHomeManageBookmarks(appStatus);
        break;
      case OnboardingType.collectionsManage:
        yield _showCollectionsManageDone(appStatus);
        break;
      case OnboardingType.bookmarksManage:
        yield _showBookmarksManageDone(appStatus);
        break;
    }
  }

  bool _showHomeVerticalSwipe(AppStatus appStatus) {
    if (appStatus.onboardingStatus.homeVerticalSwipeDone) return false;
    return appStatus.numberOfSessions >= 1;
  }

  bool _showHomeSideSwipe(AppStatus appStatus) {
    if (appStatus.onboardingStatus.homeSideSwipeDone) return false;
    return appStatus.numberOfSessions >= 2;
  }

  bool _showHomeManageBookmarks(AppStatus appStatus) {
    if (appStatus.onboardingStatus.homeManageBookmarksDone) return false;
    if (appStatus.numberOfSessions < 5) return false;
    if (_collectionsRepository.getAll().length <= 2) return false;
    if (_bookmarksRepository.getAll().length <= 5) return false;
    return true;
  }

  bool _showCollectionsManageDone(AppStatus appStatus) {
    if (appStatus.onboardingStatus.collectionsManageDone) return false;
    // default `read later` should not be counted
    if (_collectionsRepository.getAll().length <= 1) return false;
    return true;
  }

  bool _showBookmarksManageDone(AppStatus appStatus) {
    if (appStatus.onboardingStatus.collectionsManageDone) return false;
    if (_bookmarksRepository.getAll().isEmpty) return false;
    return true;
  }
}
