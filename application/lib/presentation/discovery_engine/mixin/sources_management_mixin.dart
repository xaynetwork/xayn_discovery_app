import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/add_source_to_excluded_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/add_source_to_trusted_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_available_sources_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_excluded_sources_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/get_trusted_sources_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/override_sources_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/remove_source_from_excluded_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/remove_source_from_trusted_list_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin SourcesManagementMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<String, EngineEvent>? _availableSourcesListUseCaseSink;
  UseCaseSink<None, EngineEvent>? _excludedSourcesListUseCaseSink,
      _trustedSourcesListUseCaseSink;
  UseCaseSink<Source, EngineEvent>? _addSourceToExcludedListUseCaseSink,
      _addSourceToTrustedListUseCaseSink,
      _removeSourceFromExcludedListUseCaseSink,
      _removeSourceFromTrustedListUseCaseSink;
  UseCaseSink<OverrideSourcesPayload, EngineEvent>? _overrideSourcesUseCaseSink;

  @override
  Future<void> close() {
    _availableSourcesListUseCaseSink = null;

    return super.close();
  }

  /// Returns all available sources from the endpoint.
  /// Use [fuzzySearchTerm] to filter the result set.
  void getAvailableSourcesList(String fuzzySearchTerm) {
    _availableSourcesListUseCaseSink ??= _getAvailableSourcesListUseCaseSink();

    _availableSourcesListUseCaseSink!(fuzzySearchTerm);
  }

  /// Returns all currently excluded sources, as persisted within the engine.
  void getExcludedSourcesList() {
    _excludedSourcesListUseCaseSink ??= _getExcludedSourcesListUseCaseSink();

    _excludedSourcesListUseCaseSink!(none);
  }

  /// Returns all currently trusted sources, as persisted within the engine.
  void getTrustedSourcesList() {
    _trustedSourcesListUseCaseSink ??= _getTrustedSourcesListUseCaseSink();

    _trustedSourcesListUseCaseSink!(none);
  }

  /// Instructs the engine to persist a new [Source] in its excluded sources list.
  void addSourceToExcludedList(Source source) {
    _addSourceToExcludedListUseCaseSink ??=
        _getAddSourceToExcludedListUseCaseSink();

    _addSourceToExcludedListUseCaseSink!(source);
  }

  /// Instructs the engine to persist a new [Source] in its trusted sources list.
  void addSourceToTrustedList(Source source) {
    _addSourceToTrustedListUseCaseSink ??=
        _getAddSourceToTrustedListUseCaseSink();

    _addSourceToTrustedListUseCaseSink!(source);
  }

  /// Instructs the engine to remove a [Source] from its excluded sources list.
  void removeSourceFromExcludedList(Source source) {
    _removeSourceFromExcludedListUseCaseSink ??=
        _getRemoveSourceFromExcludedListUseCaseSink();

    _removeSourceFromExcludedListUseCaseSink!(source);
  }

  /// Instructs the engine to remove a [Source] from its trusted sources list.
  void removeSourceFromTrustedList(Source source) {
    _removeSourceFromTrustedListUseCaseSink ??=
        _getRemoveSourceFromTrustedListUseCaseSink();

    _removeSourceFromTrustedListUseCaseSink!(source);
  }

  void overrideSources({
    required Set<Source> trustedSources,
    required Set<Source> excludedSources,
  }) {
    _overrideSourcesUseCaseSink ??= _getOverrideSourcesUseCaseSink();

    _overrideSourcesUseCaseSink!(OverrideSourcesPayload(
        trustedSources: trustedSources, excludedSources: excludedSources));
  }

  UseCaseSink<String, EngineEvent> _getAvailableSourcesListUseCaseSink() {
    final useCase = di.get<GetAvailableSourcesListUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<None, EngineEvent> _getExcludedSourcesListUseCaseSink() {
    final useCase = di.get<GetExcludedSourcesListUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<None, EngineEvent> _getTrustedSourcesListUseCaseSink() {
    final useCase = di.get<GetTrustedSourcesListUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<Source, EngineEvent> _getAddSourceToExcludedListUseCaseSink() {
    final useCase = di.get<AddSourceToExcludedListUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<Source, EngineEvent> _getAddSourceToTrustedListUseCaseSink() {
    final useCase = di.get<AddSourceToTrustedListUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<Source, EngineEvent>
      _getRemoveSourceFromExcludedListUseCaseSink() {
    final useCase = di.get<RemoveSourceFromExcludedListUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<Source, EngineEvent>
      _getRemoveSourceFromTrustedListUseCaseSink() {
    final useCase = di.get<RemoveSourceFromTrustedListUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  UseCaseSink<OverrideSourcesPayload, EngineEvent>
      _getOverrideSourcesUseCaseSink() {
    final useCase = di.get<OverrideSourcesUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
