import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/fetch_remote_config_use_case.dart';

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
  CheckRemoteConfigPromoCodeUseCase(
      this._fetchUseCase, this._appStatusRepository);

  final FetchRemoteConfigUseCase _fetchUseCase;
  final AppStatusRepository _appStatusRepository;

  @override
  Stream<PromoCodeResult> transaction(String param) async* {
    final isAlreadyUsed =
        _appStatusRepository.appStatus.usedPromoCodes.contains(param);
    final config = await _fetchUseCase.singleOutput(none);
    if (config != null) {
      yield PromoCodeResult(
          config.promoCodes.firstWhereOrNull((e) => e.code == param),
          isAlreadyUsed);
    } else {
      yield PromoCodeResult(null, isAlreadyUsed);
    }
  }
}
