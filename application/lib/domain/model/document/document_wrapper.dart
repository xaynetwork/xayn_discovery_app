import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';

import '../unique_id.dart';

class DocumentWrapper extends Equatable implements DbEntity {
  const DocumentWrapper(
    this.document, {
    this.isEngineDocument = true,
  });

  @override
  UniqueId get id => document.documentId.uniqueId;
  final Document document;

  // Indicates if the document comes from the engine.
  // This will be false when we fetch documents in the background
  // to be used in push notifications.
  final bool isEngineDocument;

  @override
  List<Object> get props => [document, isEngineDocument];
}
