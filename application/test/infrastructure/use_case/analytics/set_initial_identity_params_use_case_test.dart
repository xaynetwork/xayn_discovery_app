import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/last_seen_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/identity/number_of_total_sessions_identity_param.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_initial_identity_params_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late SetInitialIdentityParamsUseCase useCase;
  late MockAppStatusRepository repository;
  late MockAnalyticsService analyticsService;

  const numberOfSessions = 42;
  final lastSeenDate = DateTime.now();
  setUp(() {
    repository = MockAppStatusRepository();
    analyticsService = MockAnalyticsService();
    useCase = SetInitialIdentityParamsUseCase(repository, analyticsService);

    final status = AppStatus.initial().copyWith(
      lastSeenDate: lastSeenDate,
      numberOfSessions: numberOfSessions,
    );
    when(repository.appStatus).thenReturn(status);
  });

  test(
    'GIVEN useCase THEN verify call are correct',
    () async {
      final params = {
        const NumberOfTotalSessionIdentityParam(numberOfSessions),
        LastSeenIdentityParam(lastSeenDate),
      };

      final result = await useCase.singleOutput(none);

      expect(result, isA<None>());

      verifyInOrder([
        repository.appStatus,
        analyticsService.updateIdentityParams(params)
      ]);

      verifyNoMoreInteractions(repository);
      verifyNoMoreInteractions(analyticsService);
    },
  );
}
