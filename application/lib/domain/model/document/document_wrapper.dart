import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/models/document.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../unique_id.dart';

class DocumentWrapper extends Equatable implements DbEntity {
  const DocumentWrapper(this.document);

  @override
  UniqueId get id => document.documentId.uniqueId;
  final Document document;

  @override
  List<Object?> get props => [document];
}
