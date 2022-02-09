import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class GetExplicitDocumentFeedbackUseCase
    extends UseCase<DocumentId, DocumentFeedback> {
  final ExplicitDocumentFeedbackRepository _explicitDocumentFeedbackRepository;

  GetExplicitDocumentFeedbackUseCase(this._explicitDocumentFeedbackRepository);

  @override
  Stream<DocumentFeedback> transaction(DocumentId param) async* {
    final id = UniqueId.fromTrustedString(param.toString());
    final startValue =
        _explicitDocumentFeedbackRepository.getById(id)?.feedback ??
            DocumentFeedback.neutral;

    yield* _explicitDocumentFeedbackRepository
        .watch(id: id)
        .whereType<ChangedEvent<ExplicitDocumentFeedback>>()
        .map((it) => it.newObject.feedback)
        .startWith(startValue);
  }
}
