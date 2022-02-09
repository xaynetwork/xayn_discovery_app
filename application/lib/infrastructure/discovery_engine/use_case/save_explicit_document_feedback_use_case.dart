import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/repository/explicit_document_feedback_repository.dart';

@injectable
class SaveExplicitDocumentFeedbackUseCase
    extends UseCase<ExplicitDocumentFeedback, ExplicitDocumentFeedback> {
  final ExplicitDocumentFeedbackRepository _explicitDocumentFeedbackRepository;

  SaveExplicitDocumentFeedbackUseCase(this._explicitDocumentFeedbackRepository);

  @override
  Stream<ExplicitDocumentFeedback> transaction(
      ExplicitDocumentFeedback param) async* {
    _explicitDocumentFeedbackRepository.save(param);

    yield param;
  }
}
