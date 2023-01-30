import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

@singleton
class DocumentMapper extends BaseDbEntityMapper<DocumentWrapper> {
  @override
  DocumentWrapper? fromMap(Map? map) {
    if (map == null) return null;

    final json =
        map[DocumentBookmarkMapperFields.json] as Map<dynamic, dynamic>;
    final isEngineDocument =
        map[DocumentBookmarkMapperFields.isEngineDocument] as bool?;

    return DocumentWrapper(
      Document.fromJson(json.cast()),
      isEngineDocument: isEngineDocument ?? true,
    );
  }

  @override
  DbEntityMap toMap(DocumentWrapper entity) => {
        DocumentBookmarkMapperFields.id: entity.id.value,
        DocumentBookmarkMapperFields.json: entity.document.toJson(),
        DocumentBookmarkMapperFields.isEngineDocument: entity.isEngineDocument,
      };

  @override
  void throwMapperException([
    String exceptionText =
        'BookmarkMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class DocumentBookmarkMapperFields {
  const DocumentBookmarkMapperFields._();

  static const int id = 0;
  static const int json = 1;
  static const int isEngineDocument = 2;
}
