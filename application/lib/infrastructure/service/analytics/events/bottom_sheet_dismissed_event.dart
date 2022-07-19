import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';

const String _kEventType = 'bottomSheetDismissed';
const String _kParamBottomSheetView = 'bottomSheetView';
const String _kParamDuration = 'duration';

class BottomSheetDismissedEvent extends AnalyticsEvent {
  BottomSheetDismissedEvent({
    required BottomSheetView bottomSheetView,
    required Duration duration,
  }) : super(
          _kEventType,
          properties: {
            _kParamBottomSheetView: bottomSheetView.name,
            _kParamDuration: duration.inSeconds,
          },
        );
}

enum BottomSheetView {
  saveToCollection,
  moveMultipleBookmarksToCollection,
  createCollection,
  renameCollection,
  confirmDeletingCollection,
  onBoardingCollectionOptions,
  onBoardingManageCollection,
  onBoardingManageBookmark,
  onBoardingLikeAndDislike,
  onBoardingNextArticle,
  onBoardingLongPressSaveArticle,
}

extension OnboardingTypeExtension on OnboardingType {
  BottomSheetView get toBottomSheetView {
    switch (this) {
      case OnboardingType.homeVerticalSwipe:
        return BottomSheetView.onBoardingNextArticle;
      case OnboardingType.homeHorizontalSwipe:
        return BottomSheetView.onBoardingLikeAndDislike;
      case OnboardingType.collectionsManage:
        return BottomSheetView.onBoardingManageCollection;
      case OnboardingType.bookmarksManage:
        return BottomSheetView.onBoardingManageBookmark;
      case OnboardingType.homeBookmarksManage:
        return BottomSheetView.onBoardingLongPressSaveArticle;
    }
  }
}
