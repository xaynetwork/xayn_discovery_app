import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

abstract class DocumentRepository {
  void save(DocumentWrapper document);
  List<DocumentWrapper> getAll();
  DocumentWrapper? getById(UniqueId id);
  DocumentWrapper? getByDocumentId(DocumentId id);
  void remove(DocumentWrapper bookmark);
}
