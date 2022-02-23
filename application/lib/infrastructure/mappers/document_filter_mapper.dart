import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

@singleton
class DocumentFilterMapper extends BaseDbEntityMapper<DocumentFilter> {
  @override
  DocumentFilter? fromMap(Map? map) {
    if (map == null) return null;

    final id =
        map[DocumentFilterMapperFields.id] ?? throwMapperException() as String;

    final filter = map[DocumentFilterMapperFields.filter] ??
        throwMapperException() as String;

    final type =
        map[DocumentFilterMapperFields.type] ?? throwMapperException() as int;

    return DocumentFilter(
      id: UniqueId.fromTrustedString(id),
      filter: filter,
      type: type == 0
          ? DocumentFilterType.source
          : type == 1
              ? DocumentFilterType.topic
              : throw "DocumentFilterType  $type unknown.",
    );
  }

  @override
  DbEntityMap toMap(DocumentFilter entity) => {
        DocumentFilterMapperFields.id: entity.id.value,
        DocumentFilterMapperFields.filter: entity.filter,
        DocumentFilterMapperFields.type:
            entity.type == DocumentFilterType.source
                ? 0
                : entity.type == DocumentFilterType.topic
                    ? DocumentFilterType.topic
                    : throw "DocumentFilterType  ${entity.type} unknown.",
      };

  @override
  void throwMapperException([
    String exceptionText =
        'DocumentFilterMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class DocumentFilterMapperFields {
  const DocumentFilterMapperFields._();

  static const int id = 0;
  static const int filter = 1;
  static const int type = 2;
}
