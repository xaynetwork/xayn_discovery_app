import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/session_id.dart';

/// A [UseCase] which gathers a pair of unique IDs as [ReportingKeys], which we use for reporting.
@injectable
class ReportingKeysUseCase extends UseCase<None, ReportingKeys> {
  final AppSettingsRepository appSettingsRepository;
  final SessionId sessionId;

  ReportingKeysUseCase(
    this.appSettingsRepository,
    this.sessionId,
  );

  @override
  Stream<ReportingKeys> transaction(None param) async* {
    yield ReportingKeys(
      installationId: appSettingsRepository.settings.installationId,
      sessionId: sessionId.key,
    );
  }
}

/// Contains keys required for reporting.
class ReportingKeys extends Equatable {
  final UniqueId installationId;
  final UniqueId sessionId;

  const ReportingKeys({
    required this.installationId,
    required this.sessionId,
  });

  @override
  List<Object> get props => [
        installationId,
        sessionId,
      ];
}
