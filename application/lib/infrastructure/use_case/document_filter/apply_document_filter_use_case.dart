import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_document_filter_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/apply_document_filter_in.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class ApplyDocumentFilterUseCase extends UseCase<ApplyDocumentFilterIn, void> {
  final HiveDocumentFilterRepository _repository;
  final DiscoveryEngine _engine;

  ApplyDocumentFilterUseCase(this._repository, this._engine);

  @override
  Stream<void> transaction(ApplyDocumentFilterIn param) async* {
    yield param.map(applyChangesToDbAndEngine: (changes) {
      _applyChangesToRepository(changes.changes);
      return _syncDocumentFiltersWithEngine();
    }, syncEngineWithDb: (sync) {
      return _syncDocumentFiltersWithEngine();
    });
  }

  void _applyChangesToRepository(Map<DocumentFilter, bool> pendingChanges) {
    final currentStored = _repository.getAll();
    for (var entry in pendingChanges.entries) {
      final isStored = currentStored.contains(entry.key);
      final shouldChange = isStored != entry.value;

      if (shouldChange) {
        if (isStored) {
          _repository.remove(entry.key);
        } else {
          _repository.save(entry.key);
        }
      }
    }
  }

  void _syncDocumentFiltersWithEngine() async {
    final event = await _engine.getExcludedSourcesList();
    if (event is ExcludedSourcesListRequestSucceeded) {
      final engineSources = event.excludedSources
          .map((e) => DocumentFilter.fromSource(e.value))
          .toSet();
      final repoSources =
          _repository.getAll().where((element) => element.isSource).toSet();

      final toBeRemoved =
          engineSources.where((element) => !repoSources.contains(element));
      final toBeAdded =
          repoSources.where((element) => !engineSources.contains(element));

      for (var source in toBeRemoved) {
        final event = await _engine.removeSourceFromExcludedList(
          source.fold((host) => Source(host),
              (topic) => throw '$topic is not a source!'),
        );
        _handleError(event);
      }

      for (var source in toBeAdded) {
        final event = await _engine.addSourceToExcludedList(
          source.fold((host) => Source(host),
              (topic) => throw '$topic is not a source!'),
        );
        _handleError(event);
      }
    }
  }

  void _handleError(EngineEvent event) {
    if (event is EngineExceptionRaised) {
      logger.e(event.message, event.stackTrace);
    }
  }
}
