import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';

@injectable
class CrudExplicitDocumentFeedbackUseCase
    extends DbEntityCrudUseCase<ExplicitDocumentFeedback> {
  CrudExplicitDocumentFeedbackUseCase(
      HiveExplicitDocumentFeedbackRepository explicitDocumentFeedbackRepository)
      : super(explicitDocumentFeedbackRepository);
}
