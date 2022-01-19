import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/session_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reporting/reporting_keys_use_case.dart';

import 'reporting_keys_use_case_test.mocks.dart';

@GenerateMocks([
  AppSettingsRepository,
  SessionId,
])
void main() {
  late MockAppSettingsRepository appSettingsRepository;
  late MockSessionId sessionId;
  late ReportingKeysUseCase reportingKeysUseCase;

  const installationIdKey = UniqueId.fromTrustedString('abc123');
  const sessionIdKey = UniqueId.fromTrustedString('xyz789');

  setUp(() {
    appSettingsRepository = MockAppSettingsRepository();
    sessionId = MockSessionId();

    when(appSettingsRepository.settings).thenReturn(
      AppSettings.global(
        isOnboardingDone: true,
        appTheme: AppTheme.system,
        installationId: installationIdKey,
      ),
    );
    when(sessionId.key).thenReturn(sessionIdKey);

    reportingKeysUseCase =
        ReportingKeysUseCase(appSettingsRepository, sessionId);
  });

  useCaseTest<ReportingKeysUseCase, None, ReportingKeys>(
    'Get a combination of the installation and session Ids ',
    build: () => reportingKeysUseCase,
    input: [none],
    expect: [
      useCaseSuccess(
        const ReportingKeys(
          installationId: installationIdKey,
          sessionId: sessionIdKey,
        ),
      )
    ],
  );
}
