import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_operation.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_task.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

abstract class SourcesPendingOperations {
  void clear();

  bool containsRemoveFromExcludedSources(Source source);
  bool containsAddToExcludedSources(Source source);

  bool containsRemoveFromTrustedSources(Source source);
  bool containsAddToTrustedSources(Source source);

  Set<SourcesManagementOperation> toSet();

  void addOperation(SourcesManagementOperation operation);

  bool removeOperation(SourcesManagementOperation operation);

  void removeOperationsBySource(Source source);

  Iterable<Source> sourcesByTask(SourcesManagementTask task);
}

@Injectable(as: SourcesPendingOperations)
class InMemorySourcesPendingOperations implements SourcesPendingOperations {
  final Set<SourcesManagementOperation> _operations =
      <SourcesManagementOperation>{};

  @override
  void clear() => _operations.clear();

  @override
  bool containsRemoveFromExcludedSources(Source source) =>
      _operations.any((it) =>
          it.task == SourcesManagementTask.removeFromExcludedSources &&
          it.source == source);

  @override
  bool containsAddToExcludedSources(Source source) => _operations.any((it) =>
      it.task == SourcesManagementTask.addToExcludedSources &&
      it.source == source);

  @override
  bool containsRemoveFromTrustedSources(Source source) =>
      _operations.any((it) =>
          it.task == SourcesManagementTask.removeFromTrustedSources &&
          it.source == source);

  @override
  bool containsAddToTrustedSources(Source source) => _operations.any((it) =>
      it.task == SourcesManagementTask.addToTrustedSources &&
      it.source == source);

  @override
  Set<SourcesManagementOperation> toSet() => _operations.toSet();

  @override
  void addOperation(SourcesManagementOperation operation) => _operations
    ..removeWhere((it) => it.source == operation.source)
    ..add(operation);

  @override
  bool removeOperation(SourcesManagementOperation operation) =>
      _operations.remove(operation);

  @override
  void removeOperationsBySource(Source source) =>
      _operations.removeWhere((it) => it.source == source);

  @override
  Iterable<Source> sourcesByTask(SourcesManagementTask task) =>
      _operations.where((it) => it.task == task).map((it) => it.source);
}
