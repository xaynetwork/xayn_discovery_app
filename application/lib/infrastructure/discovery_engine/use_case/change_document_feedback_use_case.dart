import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class ChangeDocumentFeedbackUseCase
    extends UseCase<DocumentFeedbackChange, EngineEvent> {
  final DiscoveryEngine _engine;

  ChangeDocumentFeedbackUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(DocumentFeedbackChange param) async* {
    yield await _engine.changeUserReaction(
      documentId: param.documentId,
      userReaction: param.userReaction,
    );
  }
}

class DocumentFeedbackChange {
  final DocumentId documentId;
  final UserReaction userReaction;

  const DocumentFeedbackChange({
    required this.documentId,
    required this.userReaction,
  });
}
