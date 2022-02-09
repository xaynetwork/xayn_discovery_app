import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/explicit_document_feedback_repository.dart';

@injectable
class CrudExplicitDocumentFeedbackUseCase extends UseCase<
    CrudExplicitDocumentFeedbackUseCaseIn, ExplicitDocumentFeedback> {
  final ExplicitDocumentFeedbackRepository _explicitDocumentFeedbackRepository;

  CrudExplicitDocumentFeedbackUseCase(this._explicitDocumentFeedbackRepository);

  @override
  Stream<ExplicitDocumentFeedback> transaction(
      CrudExplicitDocumentFeedbackUseCaseIn param) async* {
    switch (param.operation) {
      case _Operation.watch:
        yield* _watch(param);
        break;
      case _Operation.store:
        yield* _store(param);
        break;
      case _Operation.remove:
        yield* _remove(param);
        break;
    }
  }

  Stream<ExplicitDocumentFeedback> _watch(
      CrudExplicitDocumentFeedbackUseCaseIn param) async* {
    final startValue = _explicitDocumentFeedbackRepository
            .getById(param.explicitDocumentFeedback.id) ??
        param.explicitDocumentFeedback;

    yield* _explicitDocumentFeedbackRepository
        .watch(id: param.explicitDocumentFeedback.id)
        .whereType<ChangedEvent<ExplicitDocumentFeedback>>()
        .map((it) => it.newObject)
        .startWith(startValue)
        .distinct();
  }

  Stream<ExplicitDocumentFeedback> _store(
      CrudExplicitDocumentFeedbackUseCaseIn param) async* {
    _explicitDocumentFeedbackRepository.save(param.explicitDocumentFeedback);

    yield param.explicitDocumentFeedback;
  }

  Stream<ExplicitDocumentFeedback> _remove(
      CrudExplicitDocumentFeedbackUseCaseIn param) async* {
    final entry = _explicitDocumentFeedbackRepository
        .getById(param.explicitDocumentFeedback.id);

    if (entry != null) {
      _explicitDocumentFeedbackRepository.remove(entry);

      yield entry;
    }
  }
}

enum _Operation { watch, store, remove }

class CrudExplicitDocumentFeedbackUseCaseIn {
  final _Operation operation;
  final ExplicitDocumentFeedback explicitDocumentFeedback;

  const CrudExplicitDocumentFeedbackUseCaseIn.watch(
      this.explicitDocumentFeedback)
      : operation = _Operation.watch;
  const CrudExplicitDocumentFeedbackUseCaseIn.store(
      this.explicitDocumentFeedback)
      : operation = _Operation.store;
  const CrudExplicitDocumentFeedbackUseCaseIn.remove(
      this.explicitDocumentFeedback)
      : operation = _Operation.remove;
}
