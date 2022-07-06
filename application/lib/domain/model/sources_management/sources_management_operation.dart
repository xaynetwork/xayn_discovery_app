import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_task.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class SourcesManagementOperation extends Equatable {
  final Source source;
  final SourcesManagementTask task;

  const SourcesManagementOperation.removeFromExcludedSources(this.source)
      : task = SourcesManagementTask.removeFromExcludedSources;
  const SourcesManagementOperation.addToExcludedSources(this.source)
      : task = SourcesManagementTask.addToExcludedSources;
  const SourcesManagementOperation.removeFromTrustedSources(this.source)
      : task = SourcesManagementTask.removeFromTrustedSources;
  const SourcesManagementOperation.addToTrustedSources(this.source)
      : task = SourcesManagementTask.addToTrustedSources;

  @override
  List<Object?> get props => [source, task];
}
