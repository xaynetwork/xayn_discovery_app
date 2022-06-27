import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

const kExtendedTestPeriodSKU = "extended_test_period";

@injectable
class ApplyPromoCodeUseCase extends UseCase<PromoCode, bool> {
  ApplyPromoCodeUseCase(this._appStatusRepository);

  final AppStatusRepository _appStatusRepository;

  @override
  Stream<bool> transaction(PromoCode param) async* {
    final duration = param.grantedDuration;
    if (param.isValid &&
        param.grantedSku == kExtendedTestPeriodSKU &&
        duration != null) {
      final status = _appStatusRepository.appStatus;
      final previousTrialEndDate = status.trialEndDate.isAfter(DateTime.now())
          ? status.trialEndDate
          : DateTime.now();
      _appStatusRepository.save(status.copyWith(
          extraTrialEndDate: previousTrialEndDate.add(duration)));
      yield true;
    } else {
      yield false;
    }
  }
}
