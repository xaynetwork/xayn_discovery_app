import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';

import '../../../test_utils/utils.dart';
import '../../../test_utils/widget_test_utils.dart';

void main() {
  late RatingDialogManager manager;
  late MockInAppReview appReview;
  late AppStatusRepository appStatusRepository;
  setUp(() async {
    await setupWidgetTest();
    appReview = MockInAppReview();
    when(appReview.isAvailable())
        .thenAnswer((realInvocation) => Future.value(true));
  });

  void _createManager(
      {bool ratingAlreadyVisible = false, int numberOfSessions = 1}) {
    appStatusRepository = di.get();
    appStatusRepository.save(appStatusRepository.appStatus.copyWith(
        ratingDialogAlreadyVisible: ratingAlreadyVisible,
        numberOfSessions: numberOfSessions));
    manager = RatingDialogManager.test(di.get(), appReview, di.get(), di.get());
  }

  test("Initially we don't show the rating dialog", () async {
    _createManager();

    expect(await manager.completedBookmarking(), false);
    verifyNever(appReview.requestReview());
  });

  test(
      "After the third session we will show the RatingDialog when completing bookmark flow",
      () async {
    _createManager(numberOfSessions: 3);

    expect(await manager.completedBookmarking(), true);
    verify(appReview.requestReview());
  });

  test(
      "After the third session we will show the RatingDialog completing share to a friend",
      () async {
    _createManager(numberOfSessions: 3);

    expect(await manager.shareWithFriendsCompleted(), true);
    verify(appReview.requestReview());
  });

  test(
      "After the third session we will show the RatingDialog completing share a Document",
      () async {
    _createManager(numberOfSessions: 3);

    expect(await manager.shareWithFriendsCompleted(), true);
    verify(appReview.requestReview());
  });

  test(
      "After the any number larger than 3 session we will show the RatingDialog completing any action",
      () async {
    _createManager(numberOfSessions: 5);

    expect(await manager.shareWithFriendsCompleted(), true);
    verify(appReview.requestReview());
  });

  test(
      "After the any number below than 3 sessions we will NOT show the RatingDialog",
      () async {
    _createManager(numberOfSessions: 2);

    expect(await manager.completedBookmarking(), false);
    verifyNever(appReview.requestReview());
  });

  test("After showing the dialog once, we never show it again.", () async {
    _createManager(numberOfSessions: 3);
    expect(await manager.completedBookmarking(), true);
    verify(appReview.requestReview());
    reset(appReview);

    expect(await manager.completedBookmarking(), false);
    verifyNever(appReview.requestReview());
    expect(appStatusRepository.appStatus.ratingDialogAlreadyVisible, true);
  });

  test("When the rating dialog was visible before, never show it again.",
      () async {
    _createManager(numberOfSessions: 3, ratingAlreadyVisible: true);

    expect(await manager.shareWithFriendsCompleted(), false);
    verifyNever(appReview.requestReview());
  });
}
