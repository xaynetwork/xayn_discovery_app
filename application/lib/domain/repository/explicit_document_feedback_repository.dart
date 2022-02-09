import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class ExplicitDocumentFeedbackRepository {
  void save(ExplicitDocumentFeedback explicitDocumentFeedback);
  ExplicitDocumentFeedback? getById(UniqueId id);
  Stream<RepositoryEvent<ExplicitDocumentFeedback>> watch({UniqueId? id});
  void remove(ExplicitDocumentFeedback entity);
}
