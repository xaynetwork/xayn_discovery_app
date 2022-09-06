import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/base/identity_param.dart';

@injectable
class SetIdentityParamsUseCase extends UseCase<Set<IdentityParam>, None> {
  final AnalyticsService _analyticsService;

  SetIdentityParamsUseCase(
    this._analyticsService,
  );

  @override
  Stream<None> transaction(Set<IdentityParam> param) async* {
    await _analyticsService.updateIdentityParams(param);

    yield none;
  }
}
