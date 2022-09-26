import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

@injectable
class HandleCountrySelectionClickedUseCase extends UseCase<None, None> {
  final AppStatusRepository appStatusRepository;

  HandleCountrySelectionClickedUseCase(
    this.appStatusRepository,
  );

  @override
  Stream<None> transaction(None param) async* {
    /// Get the current status of the data
    final appStatus = appStatusRepository.appStatus;
    final cta = appStatus.cta;
    final countrySelection = cta.countrySelection;

    /// Update the status of the data
    final updatedCta = cta.copyWith(
      countrySelection: countrySelection.clicked(
        sessionNumber: appStatus.numberOfSessions,
      ),
    );
    final updatedAppStatus = appStatus.copyWith(cta: updatedCta);
    appStatusRepository.save(updatedAppStatus);

    yield none;
  }
}
