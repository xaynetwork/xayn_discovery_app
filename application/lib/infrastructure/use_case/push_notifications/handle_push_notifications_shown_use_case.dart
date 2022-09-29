//handle_survey_banner_shown_use_caseimport 'package:injectable/injectable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@lazySingleton
class HandlePushNotificationsShownUseCase extends UseCase<None, None> {
  final AppStatusRepository _repository;
  bool hasBeenShown = false;

  HandlePushNotificationsShownUseCase(this._repository);

  @override
  Stream<None> transaction(param) async* {
    /// Avoid that the number of time shown is updated more than once in the same session
    if (!hasBeenShown) {
      /// Get the current status of the data
      final appStatus = _repository.appStatus;
      final cta = appStatus.cta;
      final pushNotifications = appStatus.cta.pushNotifications;

      /// Update the status of the data
      final updatedPushNotifications = pushNotifications.copyWith(
          numberOfTimesShown: pushNotifications.numberOfTimesShown + 1);
      final updatedCta =
          cta.copyWith(pushNotifications: updatedPushNotifications);
      final updatedAppStatus = appStatus.copyWith(
        cta: updatedCta,
      );
      _repository.save(updatedAppStatus);

      hasBeenShown = true;
    }

    yield none;
  }
}
