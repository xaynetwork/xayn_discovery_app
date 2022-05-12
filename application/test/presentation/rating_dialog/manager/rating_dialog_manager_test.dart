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
    manager = RatingDialogManager.test(
        di.get(), appReview, di.get(), di.get(), di.get());
  }

  test("Initially we don't show the rating dialog", () async {
    _createManager();

    expect(await manager.completedBookmarking(), false);
    verifyNever(appReview.requestReview());
  });

  test(
      "After the third session we will show the dialog when clicking on bookmarked",
      () async {
    _createManager(numberOfSessions: 3);

    expect(await manager.completedBookmarking(), true);
    verify(appReview.requestReview());
  });
}
