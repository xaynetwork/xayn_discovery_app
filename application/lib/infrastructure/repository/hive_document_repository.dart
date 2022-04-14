import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/repository/document_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import 'hive_repository.dart';

@Singleton(as: DocumentRepository)
class HiveDocumentRepository extends HiveRepository<DocumentWrapper>
    implements DocumentRepository {
  final DocumentMapper _mapper;

  HiveDocumentRepository(this._mapper);

  @override
  Box<Record> get box => Hive.box<Record>(BoxNames.documents);

  @override
  BaseDbEntityMapper<DocumentWrapper> get mapper => _mapper;

  @override
  DocumentWrapper? getByDocumentId(DocumentId id) => getById(id.uniqueId);
}
