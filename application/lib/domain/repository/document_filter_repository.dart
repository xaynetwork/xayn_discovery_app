import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class DocumentFilterRepository {
  void save(DocumentFilter filter);
  List<DocumentFilter> getAll();
  void remove(DocumentFilter filter);
  Stream<RepositoryEvent> watch({UniqueId id});
}
