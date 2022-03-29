import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';

part 'apply_document_filter_in.freezed.dart';

@freezed
class ApplyDocumentFilterIn with _$ApplyDocumentFilterIn {
  const ApplyDocumentFilterIn._();

  const factory ApplyDocumentFilterIn.applyChangesToDbAndEngine({
    required Map<DocumentFilter, bool> changes,
  }) = ApplyChanges;

  const factory ApplyDocumentFilterIn.syncEngineWithDb() = ApplySync;
}
