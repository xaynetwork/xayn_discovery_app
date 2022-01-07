import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

mixin CloseFeedDocumentsMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<Set<DocumentId>, EngineEvent>>? _useCaseSink;

  void closeFeedDocuments(Set<DocumentId> documents) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(documents);
  }

  Future<UseCaseSink<Set<DocumentId>, EngineEvent>> _getUseCaseSink() async {
    final useCase = await di.getAsync<CloseFeedDocumentsUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
