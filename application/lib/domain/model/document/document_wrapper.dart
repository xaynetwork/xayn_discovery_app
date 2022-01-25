import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/models/document.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../unique_id.dart';

class DocumentWrapper extends Equatable implements DbEntity, Document {
  DocumentWrapper(Document document) : _document = document;

  @override
  UniqueId get id => _document.documentId.uniqueId;
  final Document _document;

  @override
  $DocumentCopyWith<Document> get copyWith => _document.copyWith;

  @override
  DocumentId get documentId => _document.documentId;

  @override
  DocumentFeedback get feedback => _document.feedback;

  @override
  bool get isActive => _document.isActive;

  @override
  int get nonPersonalizedRank => _document.nonPersonalizedRank;

  @override
  int get personalizedRank => _document.personalizedRank;

  @override
  Map<String, dynamic> toJson() => _document.toJson();

  @override
  WebResource get webResource => _document.webResource;

  @override
  List<Object?> get props => [_document];
}
