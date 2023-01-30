import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/discovery_engine.dart';

@injectable
class LogDocumentTimeUseCase extends UseCase<LogData, EngineEvent> {
  final DiscoveryEngine _engine;

  LogDocumentTimeUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(LogData param) async* {
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
