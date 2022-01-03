import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_stored_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/save_app_version_use_case.dart';

@injectable
class RatingDialogManager {
  RatingDialogManager(
    this._getAppVersionUseCase,
    this._getStoredAppVersionUseCase,
    this._saveAppVersionUseCase,
  );

  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetStoredAppVersionUseCase _getStoredAppVersionUseCase;
  final SaveAppVersionUseCase _saveAppVersionUseCase;

  final Set<int> _viewedCardIndices = {};
  static const _viewedCardsThreshold = 8;

  Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  void _showRatingDialog() async {
    final currentAppVersion = await _getAppVersionUseCase.singleOutput(none);
    final storedAppVersion =
        await _getStoredAppVersionUseCase.singleOutput(none);

    final shouldShowDialog = storedAppVersion < currentAppVersion;

    if (shouldShowDialog) {
      await _requestReview();
      await _saveAppVersionUseCase.call(currentAppVersion);
    }
  }

  void handleIndexChanged(int index) {
    _viewedCardIndices.add(index);
    if (_viewedCardIndices.length >= _viewedCardsThreshold) {
      _showRatingDialog();
    }
  }
}
