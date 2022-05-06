import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_feed_documents_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/singleton_subscription_observer.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin CloseFeedDocumentsMixin<T> on SingletonSubscriptionObserver<T> {
  final Set<DocumentId> _closedDocuments = <DocumentId>{};
  UseCaseSink<Set<DocumentId>, EngineEvent>? _useCaseSink;

  Set<DocumentId> get closedDocuments => _closedDocuments;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void closeFeedDocuments(Set<DocumentId> documents) {
    final crudExplicitDocumentFeedbackUseCase =
        di.get<CrudExplicitDocumentFeedbackUseCase>();

    _closedDocuments.addAll(documents);

    _useCaseSink ??= _getUseCaseSink();

    _useCaseSink!(documents);

    for (final id in documents) {
      crudExplicitDocumentFeedbackUseCase(
        DbCrudIn.remove(
          id.uniqueId,
        ),
      );
    }
  }

  UseCaseSink<Set<DocumentId>, EngineEvent> _getUseCaseSink() {
    final useCase = di.get<CloseFeedDocumentsUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
