import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:dart_remote_config/model/dart_remote_config_state.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';

class PromoCodeResult extends Equatable {
  const PromoCodeResult(this.promoCode, this.alreadyUsed);

  final PromoCode? promoCode;
  final bool alreadyUsed;

  @override
  List<Object?> get props => [promoCode, alreadyUsed];
}

@injectable
class CheckRemoteConfigPromoCodeUseCase
    extends UseCase<String, PromoCodeResult> {
  CheckRemoteConfigPromoCodeUseCase(this._state, this._appStatusRepository);

  final AppStatusRepository _appStatusRepository;
  final DartRemoteConfigState _state;

  @override
  Stream<PromoCodeResult> transaction(String param) async* {
    final isAlreadyUsed =
        _appStatusRepository.appStatus.usedPromoCodes.contains(param);
    final config = _state.mapOrNull(success: (s) => s.config);
    if (config != null) {
      yield PromoCodeResult(
          config.promoCodes.firstWhereOrNull((e) => e.code == param),
          isAlreadyUsed);
    } else {
      yield PromoCodeResult(null, isAlreadyUsed);
    }
  }
}
