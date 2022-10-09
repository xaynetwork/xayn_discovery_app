import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

const int _kNumberOfTimesShownThreshold = 1;

@injectable
class CanDisplayCountrySelectionUseCase extends UseCase<None, bool> {
  final AppStatusRepository _appStatusRepository;
  final FeatureManager _featureManager;

  CanDisplayCountrySelectionUseCase(
    this._appStatusRepository,
    this._featureManager,
  );

  @override
  Stream<bool> transaction(None param) async* {
    if (!_featureManager.isCountrySelectionInLineCardEnabled) {
      yield false;
      return;
    }

    final appStatus = _appStatusRepository.appStatus;
    final numberOfTimesShown =
        appStatus.cta.countrySelection.numberOfTimesShown;

    final canBeShown = numberOfTimesShown < _kNumberOfTimesShownThreshold;

    yield canBeShown;
  }
}
