import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class DeleteExplicitDocumentFeedbackUseCase extends UseCase<DocumentId, None> {
  final ExplicitDocumentFeedbackRepository _explicitDocumentFeedbackRepository;

  DeleteExplicitDocumentFeedbackUseCase(
      this._explicitDocumentFeedbackRepository);

  @override
  Stream<None> transaction(DocumentId param) async* {
    final id = UniqueId.fromTrustedString(param.toString());
    final entry = _explicitDocumentFeedbackRepository.getById(id);

    if (entry != null) _explicitDocumentFeedbackRepository.remove(entry);

    yield none;
  }
}
