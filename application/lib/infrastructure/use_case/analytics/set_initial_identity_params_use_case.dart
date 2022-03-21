import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/last_seen_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_total_sessions_identity_param.dart';

@injectable
class SetInitialIdentityParamsUseCase extends UseCase<None, None> {
  final AppStatusRepository _repository;
  final AnalyticsService _analyticsService;

  SetInitialIdentityParamsUseCase(
    this._repository,
    this._analyticsService,
  );

  @override
  Stream<None> transaction(None param) async* {
    final appStatus = _repository.appStatus;
    final numberOfSessions = appStatus.numberOfSessions;
    final lastSeenDate = appStatus.lastSeenDate;

    final params = {
      NumberOfTotalSessionIdentityParam(numberOfSessions),
      LastSeenIdentityParam(lastSeenDate),
    };

    await _analyticsService.updateIdentityParams(params);

    yield none;
  }
}
