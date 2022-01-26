import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@singleton
class DocumentMapper extends BaseDbEntityMapper<DocumentWrapper> {
  @override
  DocumentWrapper? fromMap(Map? map) {
    if (map == null) return null;

    final json = map[BookmarkMapperFields.json];

    return DocumentWrapper(Document.fromJson(json));
  }

  @override
  DbEntityMap toMap(DocumentWrapper entity) => {
        BookmarkMapperFields.id: entity.id.value,
        BookmarkMapperFields.json: entity.document.toJson(),
      };

  @override
  void throwMapperException([
    String exceptionText =
        'BookmarkMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class BookmarkMapperFields {
  const BookmarkMapperFields._();

  static const int id = 0;
  static const int json = 1;
}
