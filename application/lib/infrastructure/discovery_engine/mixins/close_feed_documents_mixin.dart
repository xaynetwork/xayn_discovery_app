import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin CloseFeedDocumentsMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<Set<DocumentId>, EngineEvent>? _useCaseSink;

  void closeFeedDocuments(Set<DocumentId> documents) async {
    final useCaseSink = await _getUseCaseSink();

    useCaseSink(documents);
  }

  Future<UseCaseSink<Set<DocumentId>, EngineEvent>> _getUseCaseSink() async {
    var sink = _useCaseSink;

    if (sink == null) {
      final useCase = await di.getAsync<CloseFeedDocumentsUseCase>();

      sink = _useCaseSink = pipe(useCase);
    }

    return sink;
  }
}
