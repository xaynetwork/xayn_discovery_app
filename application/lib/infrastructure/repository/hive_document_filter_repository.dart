import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/domain/repository/document_filter_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_filter_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

import 'hive_repository.dart';

@singleton
class HiveDocumentFilterRepository extends HiveRepository<DocumentFilter>
    implements DocumentFilterRepository {
  HiveDocumentFilterRepository();

  @override
  late final Box<Record> box = Hive.box<Record>(BoxNames.documentFilters);

  @override
  BaseDbEntityMapper<DocumentFilter> mapper = DocumentFilterMapper();
}
