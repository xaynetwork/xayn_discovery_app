import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

@injectable
class SetIdentityParamUseCase extends UseCase<IdentityParam, None> {
  final AnalyticsService _analyticsService;

  SetIdentityParamUseCase(
    this._analyticsService,
  );

  @override
  Stream<None> transaction(IdentityParam param) async* {
    await _analyticsService.updateIdentityParam(param);

    yield none;
  }
}
