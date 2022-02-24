import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

@singleton
class DocumentFilterMapper extends BaseDbEntityMapper<DocumentFilter> {
  @override
  DocumentFilter? fromMap(Map? map) {
    if (map == null) return null;

    final filter = (map[DocumentFilterMapperFields.filter] ??
        throwMapperException()) as String;

    final type =
        (map[DocumentFilterMapperFields.type] ?? throwMapperException()) as int;

    final filterType = type.toDocumentFilterType();

    switch (filterType) {
      case DocumentFilterType.source:
        return DocumentFilter.fromSource(filter);
      case DocumentFilterType.topic:
        return DocumentFilter.fromTopic(filter);
    }
  }

  @override
  DbEntityMap toMap(DocumentFilter entity) => entity.fold(
      (source) => {
            DocumentFilterMapperFields.filter: source,
            DocumentFilterMapperFields.type: DocumentFilterType.source.toInt(),
          },
      (topic) => {
            DocumentFilterMapperFields.filter: topic,
            DocumentFilterMapperFields.type: DocumentFilterType.topic.toInt(),
          });

  @override
  void throwMapperException([
    String exceptionText =
        'DocumentFilterMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

extension on int {
  DocumentFilterType toDocumentFilterType() {
    switch (this) {
      case 0:
        return DocumentFilterType.source;

      case 1:
        return DocumentFilterType.topic;
    }
    throw "Unsupported DocumentFilterType id $this";
  }
}

extension on DocumentFilterType {
  int toInt() {
    switch (this) {
      case DocumentFilterType.source:
        return 0;
      case DocumentFilterType.topic:
        return 1;
    }
  }
}

abstract class DocumentFilterMapperFields {
  const DocumentFilterMapperFields._();

  static const int filter = 0;
  static const int type = 1;
}
