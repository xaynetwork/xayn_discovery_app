import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_stored_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/save_app_version_use_case.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_state.dart';

@injectable
class RatingDialogManager extends Cubit<RatingDialogState>
    with UseCaseBlocHelper<RatingDialogState> {
  RatingDialogManager(
    this._getAppVersionUseCase,
    this._getStoredAppVersionUseCase,
    this._saveAppVersionUseCase,
  ) : super(RatingDialogState.initial());

  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetStoredAppVersionUseCase _getStoredAppVersionUseCase;
  final SaveAppVersionUseCase _saveAppVersionUseCase;

  void showRatingDialog() async {
    final currentAppVersion = await _getAppVersionUseCase.singleOutput(none);
    final storedAppVersion =
        await _getStoredAppVersionUseCase.singleOutput(none);

    final shouldShowDialog =
        storedAppVersion != null && storedAppVersion < currentAppVersion;

    if (shouldShowDialog) {
      await _requestReview();
    }

    if (storedAppVersion == null || storedAppVersion < currentAppVersion) {
      await _saveAppVersionUseCase.call(currentAppVersion);
    }
  }

  Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }
}
