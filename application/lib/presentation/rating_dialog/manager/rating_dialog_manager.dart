import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/get_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_stored_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/save_app_version_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

/// Shows the rating dialog when any of the following conditions is met:
///
/// 1. When the user updates the app to a new version every time.
/// 2. On the third session and having scrolled over at least 8 articles.
@lazySingleton
class RatingDialogManager {
  RatingDialogManager(
    this._getAppVersionUseCase,
    this._getStoredAppVersionUseCase,
    this._saveCurrentAppVersion,
    this._getAppSessionUseCase,
    this._featureManager,
  )   : _viewedCardIndices = {},
        _inAppReview = InAppReview.instance {
    // Calling this from the constructor to handle the app update case.
    showRatingDialogIfNeeded();
  }

  @visibleForTesting
  RatingDialogManager.test(
    this._viewedCardIndices,
    this._getAppVersionUseCase,
    this._getStoredAppVersionUseCase,
    this._saveCurrentAppVersion,
    this._getAppSessionUseCase,
    this._inAppReview,
    this._featureManager,
  );

  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetStoredAppVersionUseCase _getStoredAppVersionUseCase;
  final SaveCurrentAppVersion _saveCurrentAppVersion;
  final GetAppSessionUseCase _getAppSessionUseCase;
  final InAppReview _inAppReview;
  final FeatureManager _featureManager;

  final Set<int> _viewedCardIndices;
  static const _viewedCardsThreshold = 8;
  static const _appSessionThreshold = 3;

  /// Keep track if the rating dialog was shown in the current session.
  /// This is to prevent showing it multiple times in debug builds.
  bool _ratingDialogShown = false;

  /// Keep track if the app version check was made in order to avoid
  /// calling use cases every time the user scrolls through cards
  bool _appVersionChecked = false;

  Future<void> _requestReview() async {
    _ratingDialogShown = true;
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }

  Future<bool> showRatingDialogIfNeeded() async {
    if (!_featureManager.isRatingDialogEnabled) {
      return false;
    }
    if (_ratingDialogShown) {
      return false;
    }

    // Make sure we check the app version once per app launch
    if (!_appVersionChecked) {
      _appVersionChecked = true;

      // Check if the user updated the app to a new version.
      final currentAppVersion = await _getAppVersionUseCase.singleOutput(none);
      final storedAppVersion =
          await _getStoredAppVersionUseCase.singleOutput(none);
      final shouldShowDialog = storedAppVersion < currentAppVersion;

      // Save the current app version if there was an update.
      if (shouldShowDialog) {
        await _saveCurrentAppVersion.call(none);
      }

      if (shouldShowDialog && !_ratingDialogShown) {
        await _requestReview();
        return true;
      }
    }

    // User scrolled through less cards than needed to show the dialog.
    // Returning early to avoid calling the get app session usecase.
    if (_viewedCardIndices.length < _viewedCardsThreshold) {
      return false;
    }

    // Check if the current session is third session and if the user scrolled through 8 cards.
    final numberOfSessions = await _getAppSessionUseCase.singleOutput(none);
    if (numberOfSessions == _appSessionThreshold &&
        _viewedCardIndices.length >= _viewedCardsThreshold &&
        !_ratingDialogShown) {
      _requestReview();
      return true;
    }

    return false;
  }

  // Called when the user swipe through cards on the home feed.
  void handleIndexChanged(int index) {
    _viewedCardIndices.add(index);
    showRatingDialogIfNeeded();
  }
}
