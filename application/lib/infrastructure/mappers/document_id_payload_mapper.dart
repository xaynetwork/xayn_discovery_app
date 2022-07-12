import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const String _documentId = 'documentId';

@singleton
class DocumentIdToPayloadMapper
    implements Mapper<UniqueId, Map<String, String>> {
  @override
  Map<String, String> map(UniqueId input) {
    return {_documentId: input.value};
  }
}

@singleton
class PayloadToDocumentIdMapper
    implements Mapper<Map<String, String>, UniqueId?> {
  @override
  UniqueId? map(Map<String, String> input) {
    final uniqueId = input[_documentId];
    if (uniqueId == null) return null;
    return UniqueId.fromTrustedString(uniqueId);
  }
}
