import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/close_search_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin CloseSearchMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<None, EngineEvent>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void closeSearch(Set<DocumentId> documents) {
    final crudExplicitDocumentFeedbackUseCase =
        di.get<CrudExplicitDocumentFeedbackUseCase>();

    _useCaseSink ??= _getUseCaseSink();

    _useCaseSink!(none);

    for (final id in documents) {
      crudExplicitDocumentFeedbackUseCase(
        DbEntityCrudUseCaseIn.remove(id.uniqueId),
      );
    }
  }

  UseCaseSink<None, EngineEvent> _getUseCaseSink() {
    final useCase = di.get<CloseSearchUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
