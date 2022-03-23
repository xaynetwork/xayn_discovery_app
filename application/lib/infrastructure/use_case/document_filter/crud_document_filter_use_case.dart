import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_document_filter_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';

@injectable
class CrudDocumentFilterUseCase extends DbEntityCrudUseCase<DocumentFilter> {
  final HiveDocumentFilterRepository _repository;

  CrudDocumentFilterUseCase(this._repository) : super(_repository);

  void applyChanges(Map<DocumentFilter, bool> pendingChanges) {
    final currentStored = _repository.getAll();
    for (var entry in pendingChanges.entries) {
      final isStored = currentStored.contains(entry.key);
      final shouldChange = isStored != entry.value;

      if (shouldChange) {
        if (isStored) {
          _repository.remove(entry.key);
        } else {
          _repository.save(entry.key);
        }
      }
    }
  }
}
