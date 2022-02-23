import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'document_filter.freezed.dart';

enum DocumentFilterType { source, topic }

@freezed
class DocumentFilter extends DbEntity with _$DocumentFilter {
  factory DocumentFilter({
    required UniqueId id,
    required String filter,
    required DocumentFilterType type,
  }) = _DocumentFilter;
}
