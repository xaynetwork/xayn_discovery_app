import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class ChangeDocumentFeedbackUseCase
    extends UseCase<DocumentFeedbackChange, EngineEvent> {
  final DiscoveryEngine _engine;

  ChangeDocumentFeedbackUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(DocumentFeedbackChange param) async* {
    logger.i('${param.documentId}: ${param.feedback}');

    yield await _engine.changeDocumentFeedback(
      documentId: param.documentId,
      feedback: param.feedback,
    );
  }
}

class DocumentFeedbackChange {
  final DocumentId documentId;
  final DocumentFeedback feedback;

  const DocumentFeedbackChange({
    required this.documentId,
    required this.feedback,
  });
}
