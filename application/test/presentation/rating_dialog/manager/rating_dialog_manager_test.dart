import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/get_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_stored_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/save_app_version_use_case.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';

import 'rating_dialog_manager_test.mocks.dart';

@GenerateMocks([
  GetAppVersionUseCase,
  GetStoredAppVersionUseCase,
  SaveAppVersionUseCase,
  GetAppSessionUseCase,
  InAppReview,
])
void main() {
  late MockGetAppVersionUseCase mockGetAppVersionUseCase;
  late MockGetStoredAppVersionUseCase mockGetStoredAppVersionUseCase;
  late MockSaveAppVersionUseCase mockSaveAppVersionUseCase;
  late MockGetAppSessionUseCase mockGetAppSessionUseCase;
  late MockInAppReview mockInAppReview;

  late RatingDialogManager manager;

  setUp(() async {
    mockGetAppVersionUseCase = MockGetAppVersionUseCase();
    mockGetStoredAppVersionUseCase = MockGetStoredAppVersionUseCase();
    mockSaveAppVersionUseCase = MockSaveAppVersionUseCase();
    mockGetAppSessionUseCase = MockGetAppSessionUseCase();
    mockInAppReview = MockInAppReview();
  });

  test(
      'GIVEN 3rd session and 8 card interactions THEN should show rating dialog',
      () async {
    when(mockGetAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(AppVersion.initial()));
    when(mockGetStoredAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(AppVersion.initial()));
    when(mockGetAppSessionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(3));
    when(mockInAppReview.isAvailable()).thenAnswer((_) => Future.value(false));

    manager = RatingDialogManager.test(
      {1, 2, 3, 4, 5, 6, 7, 8},
      mockGetAppVersionUseCase,
      mockGetStoredAppVersionUseCase,
      mockSaveAppVersionUseCase,
      mockGetAppSessionUseCase,
      mockInAppReview,
    );

    expect(await manager.showRatingDialogIfNeeded(), isTrue);
  });

  test(
      'GIVEN 1st session and 8 card interactions THEN should not show rating dialog',
      () async {
    when(mockGetAppSessionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(1));
    when(mockGetAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(AppVersion.initial()));
    when(mockGetStoredAppVersionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(AppVersion.initial()));
    when(mockInAppReview.isAvailable()).thenAnswer((_) => Future.value(false));

    manager = RatingDialogManager.test(
      {1, 2, 3, 4, 5, 6, 7, 8},
      mockGetAppVersionUseCase,
      mockGetStoredAppVersionUseCase,
      mockSaveAppVersionUseCase,
      mockGetAppSessionUseCase,
      mockInAppReview,
    );

    expect(await manager.showRatingDialogIfNeeded(), isFalse);
  });

  test('GIVEN version update THEN should show rating dialog', () async {
    when(mockGetAppSessionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(1));
    when(mockGetAppVersionUseCase.singleOutput(none)).thenAnswer(
        (_) => Future.value(const AppVersion(version: '0.0.2', build: '1')));
    when(mockGetStoredAppVersionUseCase.singleOutput(none)).thenAnswer(
        (_) => Future.value(const AppVersion(version: '0.0.1', build: '1')));
    when(mockSaveAppVersionUseCase.call(any))
        .thenAnswer((_) => Future.value([]));
    when(mockInAppReview.isAvailable()).thenAnswer((_) => Future.value(false));

    manager = RatingDialogManager.test(
      {},
      mockGetAppVersionUseCase,
      mockGetStoredAppVersionUseCase,
      mockSaveAppVersionUseCase,
      mockGetAppSessionUseCase,
      mockInAppReview,
    );

    expect(await manager.showRatingDialogIfNeeded(), isTrue);
  });
}
