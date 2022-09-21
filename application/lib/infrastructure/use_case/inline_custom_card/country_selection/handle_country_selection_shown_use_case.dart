import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@lazySingleton
class HandleCountrySelectionShownUseCase extends UseCase<None, None> {
  final AppStatusRepository _repository;
  bool hasBeenShown = false;

  HandleCountrySelectionShownUseCase(this._repository);

  @override
  Stream<None> transaction(param) async* {
    /// Avoid that the number of time shown is updated more than once in the same session
    if (!hasBeenShown) {
      /// Get the current status of the data
      final appStatus = _repository.appStatus;
      final cta = appStatus.cta;
      final countrySelection = appStatus.cta.countrySelection;

      /// Update the status of the data
      final updatedCountrySelection = countrySelection.copyWith(
          numberOfTimesShown: countrySelection.numberOfTimesShown + 1);
      final updatedCta =
          cta.copyWith(countrySelection: updatedCountrySelection);
      final updatedAppStatus = appStatus.copyWith(
        cta: updatedCta,
      );
      _repository.save(updatedAppStatus);

      hasBeenShown = true;
    }

    yield none;
  }
}
