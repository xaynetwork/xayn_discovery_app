import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';
import 'package:xayn_discovery_app/domain/repository/document_repository.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/discovery_engine.dart';

@injectable
class ChangeDocumentFeedbackUseCase
    extends UseCase<DocumentFeedbackChange, EngineEvent> {
  final DiscoveryEngine _engine;
  final DocumentRepository _documentRepository;

  ChangeDocumentFeedbackUseCase(
    this._engine,
    this._documentRepository,
  );

  @override
  Stream<EngineEvent> transaction(DocumentFeedbackChange param) async* {
    final document = _documentRepository.getByDocumentId(param.documentId);

    // Ignore documents that do not come from the engine (e.g. push notifications).
    if (document?.isEngineDocument == false) return;

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
