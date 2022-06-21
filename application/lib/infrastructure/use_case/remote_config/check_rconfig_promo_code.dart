import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/fetch_remote_config_use_case.dart';

@injectable
class CheckRemoteConfigPromoCode extends UseCase<String, PromoCode?> {
  CheckRemoteConfigPromoCode(this._fetchUseCase);

  final FetchRemoteConfigUseCase _fetchUseCase;

  @override
  Stream<PromoCode?> transaction(String param) async* {
    final config = await _fetchUseCase.singleOutput(none);
    if (config != null) {
      yield config.findValidPromoCode(param);
    } else {
      yield null;
    }
  }
}
