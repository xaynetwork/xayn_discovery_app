import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/onboarding_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_status_repository.dart';

/// This Migration resets the [firstAppLaunchDate], required when enabling payments in prod.
// ignore: camel_case_types
class Migration_1_To_2 extends BaseDbMigration {
  @override
  Migration_1_To_2();

  @override
  Future<int> rollbackMigration(int fromVersion) async {
    return fromVersion;
  }

  @override
  Future<int> runMigration(int fromVersion) async {
    assert(fromVersion == 1);

    const mapper = AppStatusMapper(
      MapToAppVersionMapper(),
      AppVersionToMapMapper(),
      OnboardingStatusToDbEntityMapMapper(),
      DbEntityMapToOnboardingStatusMapper(),
    );
    final repository = HiveAppStatusRepository(mapper);
    final appStatus = repository.appStatus;
    final updatedAppStatus =
        appStatus.copyWith(firstAppLaunchDate: DateTime.now());
    repository.save(updatedAppStatus);

    return 2;
  }
}
