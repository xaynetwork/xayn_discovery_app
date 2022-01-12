import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';

import '../../utils/utils.dart';

void main() {
  late MockGetAppVersionUseCase mockGetAppVersionUseCase;
  late MockGetStoredAppVersionUseCase mockGetStoredAppVersionUseCase;
  late MockSaveCurrentAppVersion mockSaveCurrentAppVersion;
  late MockGetAppSessionUseCase mockGetAppSessionUseCase;
  late MockInAppReview mockInAppReview;

  late RatingDialogManager manager;

  setUp(() async {
    mockGetAppVersionUseCase = MockGetAppVersionUseCase();
    mockGetStoredAppVersionUseCase = MockGetStoredAppVersionUseCase();
    mockSaveCurrentAppVersion = MockSaveCurrentAppVersion();
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
      mockSaveCurrentAppVersion,
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
      mockSaveCurrentAppVersion,
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
    when(mockSaveCurrentAppVersion.call(any))
        .thenAnswer((_) => Future.value([]));
    when(mockInAppReview.isAvailable()).thenAnswer((_) => Future.value(false));

    manager = RatingDialogManager.test(
      {},
      mockGetAppVersionUseCase,
      mockGetStoredAppVersionUseCase,
      mockSaveCurrentAppVersion,
      mockGetAppSessionUseCase,
      mockInAppReview,
    );

    expect(await manager.showRatingDialogIfNeeded(), isTrue);
  });

  test(
      'GIVEN showRatingDialogIfNeeded is called multiple times THEN the get app version use case is called once',
      () async {
    when(mockGetAppSessionUseCase.singleOutput(none))
        .thenAnswer((_) => Future.value(1));
    when(mockGetAppVersionUseCase.singleOutput(none)).thenAnswer(
        (_) => Future.value(const AppVersion(version: '0.0.1', build: '1')));
    when(mockGetStoredAppVersionUseCase.singleOutput(none)).thenAnswer(
        (_) => Future.value(const AppVersion(version: '0.0.1', build: '1')));
    when(mockSaveCurrentAppVersion.call(any))
        .thenAnswer((_) => Future.value([]));
    when(mockInAppReview.isAvailable()).thenAnswer((_) => Future.value(false));

    manager = RatingDialogManager.test(
      {},
      mockGetAppVersionUseCase,
      mockGetStoredAppVersionUseCase,
      mockSaveCurrentAppVersion,
      mockGetAppSessionUseCase,
      mockInAppReview,
    );

    expect(await manager.showRatingDialogIfNeeded(), isFalse);
    expect(await manager.showRatingDialogIfNeeded(), isFalse);
    verify(mockGetAppVersionUseCase.singleOutput(any));
    verifyNoMoreInteractions(mockGetAppVersionUseCase);
  });

  test(
      'GIVEN showRatingDialogIfNeeded is called multiple times and _viewedCardIndices is less than threshold THEN the get app session usecase is not called',
      () async {
    when(mockGetAppVersionUseCase.singleOutput(none)).thenAnswer(
        (_) => Future.value(const AppVersion(version: '0.0.1', build: '1')));
    when(mockGetStoredAppVersionUseCase.singleOutput(none)).thenAnswer(
        (_) => Future.value(const AppVersion(version: '0.0.1', build: '1')));
    when(mockSaveCurrentAppVersion.call(any))
        .thenAnswer((_) => Future.value([]));
    when(mockInAppReview.isAvailable()).thenAnswer((_) => Future.value(false));

    manager = RatingDialogManager.test(
      {},
      mockGetAppVersionUseCase,
      mockGetStoredAppVersionUseCase,
      mockSaveCurrentAppVersion,
      mockGetAppSessionUseCase,
      mockInAppReview,
    );

    expect(await manager.showRatingDialogIfNeeded(), isFalse);
    verifyNoMoreInteractions(mockGetAppSessionUseCase);
  });
}
