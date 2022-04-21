import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/onboarding_status_mapper.dart';

void main() {
  const statusAllTrue = OnboardingStatus(
    homeVerticalSwipeDone: true,
    homeSideSwipeDone: true,
    homeManageBookmarksDone: true,
    collectionsManageDone: true,
  );
  const statusAllFalse = OnboardingStatus(
    homeVerticalSwipeDone: false,
    homeSideSwipeDone: false,
    homeManageBookmarksDone: false,
    collectionsManageDone: false,
  );

  final mapAllTrue = {
    OnboardingStatusFields.homeVerticalSwipeDone: true,
    OnboardingStatusFields.homeSideSwipeDone: true,
    OnboardingStatusFields.homeManageBookmarksDone: true,
    OnboardingStatusFields.collectionsManageDone: true,
  };

  final mapAllFalse = {
    OnboardingStatusFields.homeVerticalSwipeDone: false,
    OnboardingStatusFields.homeSideSwipeDone: false,
    OnboardingStatusFields.homeManageBookmarksDone: false,
    OnboardingStatusFields.collectionsManageDone: false,
  };
  group('toMap', () {
    final mapper = OnboardingStatusToDbEntityMapMapper();
    test(
      'GIVEN status all true THEN return correct map',
      () {
        final output = mapper.map(statusAllTrue);
        expect(output, equals(mapAllTrue));
      },
    );
    test(
      'GIVEN status all false THEN return correct map',
      () {
        final output = mapper.map(statusAllFalse);
        expect(output, equals(mapAllFalse));
      },
    );
  });
  group('fromMap', () {
    final mapper = DbEntityMapToOnboardingStatusMapper();
    test(
      'GIVEN nullable map THEN return initial OnboardingStatus',
      () {
        final output = mapper.map(null);
        expect(output, equals(const OnboardingStatus.initial()));
      },
    );
    test(
      'GIVEN map with missing values THEN OnboardingStatus with default values',
      () {
        final output = mapper.map({});
        expect(output, equals(const OnboardingStatus.initial()));
      },
    );
    test(
      'GIVEN map with all true THEN return OnboardingStatus with correct values',
      () {
        final output = mapper.map(mapAllTrue);
        expect(output, equals(statusAllTrue));
      },
    );
    test(
      'GIVEN map with all false THEN return OnboardingStatus with correct values',
      () {
        final output = mapper.map(mapAllFalse);
        expect(output, equals(statusAllFalse));
      },
    );
  });
}
