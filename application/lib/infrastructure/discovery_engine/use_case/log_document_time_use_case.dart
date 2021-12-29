import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@lazySingleton
class LogDocumentTimeUseCase extends UseCase<LogData, EngineEvent> {
  final DiscoveryEngine _engine;

  LogDocumentTimeUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(LogData param) async* {
    logger.i(
        '${param.duration.inSeconds} seconds spent in ${param.mode} on ${param.documentId}');

    yield await _engine.logDocumentTime(
      documentId: param.documentId,
      seconds: param.duration.inSeconds,
      mode: param.mode,
    );
  }
}

class LogData {
  final DocumentId documentId;
  final DocumentViewMode mode;
  final Duration duration;

  const LogData({
    required this.documentId,
    required this.mode,
    required this.duration,
  });
}
