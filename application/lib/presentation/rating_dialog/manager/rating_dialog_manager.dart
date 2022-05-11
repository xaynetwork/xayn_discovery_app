import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_rating_already_visible/save_app_rating_already_visible_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/get_app_session_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

/// Shows the rating dialog when any of the following conditions is met:
///
/// 1. When the user updates the app to a new version every time.
/// 2. On the third session and having scrolled over at least 8 articles.
///

/// From: https://xainag.atlassian.net/browse/TB-3689
/// We ask the user the rate the News Assistant App, when when the following conditions are met
///
/// Condition 1: The user started the third session in one week (event: session_start)
/// AND Condition 2: the user performs one of the following actions
///   Condition 2A - The user bookmarks an article
///   OR Condition 2B - The user clicked on the “Share with friends” button to share the app
///   OR - Condition 2C: the user shares an article
///
/// the native rating dialogue is shown after the user performs one of the actions in Condition 2 A-C:
/// after bookmarking, in article view or feed:
/// if the user DOES NOT interact with the “Saved to later” pop-over - the rating dialogue is shown after the pop-over has disappeared
/// If the user DOES interact with the pop-over, the rating pop-up is shown once the user has saved the article in a collection and closed the bookmarking sheet again
/// After clicking the pink button to share the app with a friend: the rating pop-up is shown after the share sheet was closed again
/// After sharing an article: the rating pop-up is also shown after the share sheet was closed again
@lazySingleton
class RatingDialogManager {
  RatingDialogManager(
    this._getAppSessionUseCase,
    this._featureManager,
    this._setAppRatingAlreadyVisibleUseCase,
    this._appStatusRepository,
  ) : _inAppReview = InAppReview.instance;

  @visibleForTesting
  RatingDialogManager.test(
    this._getAppSessionUseCase,
    this._inAppReview,
    this._featureManager,
    this._setAppRatingAlreadyVisibleUseCase,
    this._appStatusRepository,
  );

  final GetAppSessionUseCase _getAppSessionUseCase;
  final SetAppRatingAlreadyVisibleUseCase _setAppRatingAlreadyVisibleUseCase;
  final AppStatusRepository _appStatusRepository;
  final InAppReview _inAppReview;
  final FeatureManager _featureManager;

  static const _appSessionThreshold = 3;

  /// Keep track if the rating dialog was shown in the current session.
  /// This is to prevent showing it multiple times in debug builds.
  late bool _ratingDialogShown =
      _appStatusRepository.appStatus.ratingDialogAlreadyVisible;

  Future<void> _requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      await _setAppRatingAlreadyVisibleUseCase.call(none);
      _ratingDialogShown = true;
    }
  }

  Future<bool> _showRatingDialogIfNeeded() async {
    if (!_featureManager.isRatingDialogEnabled) {
      return false;
    }
    if (_ratingDialogShown) {
      return false;
    }

    final numberOfSessions = await _getAppSessionUseCase.singleOutput(none);
    if (numberOfSessions >= _appSessionThreshold && !_ratingDialogShown) {
      await _requestReview();
      return true;
    }

    return false;
  }

  /// Called after a bookmarking Flow is compoleted
  /// 1. doc was bookmarked
  /// 2. no dialog / tooltip is visible anymore.
  Future<bool> completedBookmarking() {
    return _showRatingDialogIfNeeded();
  }

  /// Called after a share with friends Flow is completed
  /// In order to achieve this condition [1] this needs to be called after the app
  /// goes to foreground again. This might be impossible to detect on iOS.
  ///
  /// [1]: After clicking the pink button to share the app with a friend: the rating pop-up is shown after the share sheet was closed again
  Future<bool> shareWithFriendsCompleted() {
    return _showRatingDialogIfNeeded();
  }

  /// Called after a sharing a document Flow is completed
  /// In order to achieve this condition [1] this needs to be called after the app
  /// goes to foreground again. This might be impossible to detect on iOS.
  ///
  /// [1]: After sharing an article: the rating pop-up is also shown after the share sheet was closed again
  Future<bool> shareWithDocumentCompleted() {
    return _showRatingDialogIfNeeded();
  }
}
