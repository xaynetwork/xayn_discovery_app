import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/presentation/utils/real_time.dart';

const kExtendedTestPeriodSKU = "extended_test_period";

@injectable
class ApplyPromoCodeUseCase extends UseCase<PromoCode, bool> {
  ApplyPromoCodeUseCase(this._appStatusRepository, this._realTime);

  final AppStatusRepository _appStatusRepository;
  final RealTime _realTime;

  @override
  Stream<bool> transaction(PromoCode param) async* {
    final duration = param.grantedDuration;
    if (param.isValid &&
        param.grantedSku == kExtendedTestPeriodSKU &&
        duration != null) {
      final status = _appStatusRepository.appStatus;
      final previousTrialEndDate = status.trialEndDate.isAfter(_realTime.now)
          ? status.trialEndDate
          : _realTime.now;
      _appStatusRepository.save(status.copyWith(
          extraTrialEndDate: previousTrialEndDate.add(duration),
          usedPromoCodes: {
            ...status.usedPromoCodes,
            param.code,
          }));
      yield true;
    } else {
      yield false;
    }
  }
}
