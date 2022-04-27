import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

const defaultHomeVerticalSwipe = false;
const defaultHomeSideSwipeDone = false;
const defaultHomeManageBookmarksDone = false;
const defaultCollectionsManageDone = false;

@immutable
class OnboardingStatus extends Equatable {
  final bool homeVerticalSwipeDone;
  final bool homeSideSwipeDone;
  final bool homeManageBookmarksDone;
  final bool collectionsManageDone;

  const OnboardingStatus({
    required this.homeVerticalSwipeDone,
    required this.homeSideSwipeDone,
    required this.homeManageBookmarksDone,
    required this.collectionsManageDone,
  });

  const OnboardingStatus.initial()
      : homeVerticalSwipeDone = defaultHomeVerticalSwipe,
        homeSideSwipeDone = defaultHomeSideSwipeDone,
        homeManageBookmarksDone = defaultHomeManageBookmarksDone,
        collectionsManageDone = defaultCollectionsManageDone;

  OnboardingStatus copyWith({
    bool? homeVerticalSwipeDone,
    bool? homeSideSwipeDone,
    bool? homeManageBookmarksDone,
    bool? collectionsManageDone,
  }) {
    assert(homeVerticalSwipeDone == null || homeVerticalSwipeDone == true);
    assert(homeSideSwipeDone == null || homeSideSwipeDone == true);
    assert(homeManageBookmarksDone == null || homeManageBookmarksDone == true);
    assert(collectionsManageDone == null || collectionsManageDone == true);

    return OnboardingStatus(
      homeVerticalSwipeDone:
          homeVerticalSwipeDone ?? this.homeVerticalSwipeDone,
      homeSideSwipeDone: homeSideSwipeDone ?? this.homeSideSwipeDone,
      homeManageBookmarksDone:
          homeManageBookmarksDone ?? this.homeManageBookmarksDone,
      collectionsManageDone:
          collectionsManageDone ?? this.collectionsManageDone,
    );
  }

  @override
  List<Object> get props => [
        homeVerticalSwipeDone,
        homeSideSwipeDone,
        homeManageBookmarksDone,
        collectionsManageDone,
      ];
}
