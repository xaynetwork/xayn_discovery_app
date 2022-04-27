import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';

void main() {
  test(
    'GIVEN instance THEN verify its Equatable',
    () async {
      const instance = OnboardingStatus.initial();
      expect(instance, isA<Equatable>());
    },
  );
  test(
    'GIVEN instance THEN verify Equatable props are correct',
    () async {
      const instance = OnboardingStatus.initial();
      expect(
        instance.props,
        [
          instance.homeVerticalSwipeDone,
          instance.homeSideSwipeDone,
          instance.homeManageBookmarksDone,
          instance.collectionsManageDone,
        ],
      );
    },
  );
  test(
    'GIVEN instance WHEN main constructor used THEN all values are correct',
    () async {
      const homeVerticalSwipeDone = true;
      const homeSideSwipeDone = true;
      const homeManageBookmarksDone = true;
      const collectionsManageDone = true;

      const instance = OnboardingStatus(
        homeManageBookmarksDone: homeManageBookmarksDone,
        homeSideSwipeDone: homeSideSwipeDone,
        homeVerticalSwipeDone: homeVerticalSwipeDone,
        collectionsManageDone: collectionsManageDone,
      );

      expect(instance.homeVerticalSwipeDone, homeVerticalSwipeDone);
      expect(instance.homeSideSwipeDone, homeSideSwipeDone);
      expect(instance.homeManageBookmarksDone, homeManageBookmarksDone);
      expect(instance.collectionsManageDone, collectionsManageDone);
    },
  );
  test(
    'GIVEN instance WHEN initial constructor used THEN all values are false',
    () async {
      const instance = OnboardingStatus.initial();

      expect(instance.homeVerticalSwipeDone, isFalse);
      expect(instance.homeSideSwipeDone, isFalse);
      expect(instance.homeManageBookmarksDone, isFalse);
      expect(instance.collectionsManageDone, isFalse);
    },
  );
  test(
    'WHEN copy with false value used THEN throw exception',
    () async {
      const instance = OnboardingStatus.initial();

      expect(
        () => instance.copyWith(homeVerticalSwipeDone: false),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => instance.copyWith(homeSideSwipeDone: false),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => instance.copyWith(homeManageBookmarksDone: false),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => instance.copyWith(collectionsManageDone: false),
        throwsA(isA<AssertionError>()),
      );
    },
  );
  test(
    'WHEN copy with true value used THEN value set correctly',
    () async {
      const instance = OnboardingStatus.initial();

      expect(
        instance.copyWith(homeVerticalSwipeDone: true).homeVerticalSwipeDone,
        isTrue,
      );

      expect(
        instance.copyWith(homeSideSwipeDone: true).homeSideSwipeDone,
        isTrue,
      );

      expect(
        instance
            .copyWith(homeManageBookmarksDone: true)
            .homeManageBookmarksDone,
        isTrue,
      );

      expect(
        instance.copyWith(collectionsManageDone: true).collectionsManageDone,
        isTrue,
      );
    },
  );
}
