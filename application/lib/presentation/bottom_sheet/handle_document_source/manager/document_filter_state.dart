import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';

part 'document_filter_state.freezed.dart';

@freezed
class DocumentFilterState with _$DocumentFilterState {
  const DocumentFilterState._();

  const factory DocumentFilterState({
    required Map<DocumentFilter, bool> filters,
  }) = _DocumentFilterState;
}
