import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_document_filter_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/apply_document_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/crud_document_filter_use_case.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/source_filter_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/source_filter_settings_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../../../test_utils/fakes.dart';
import '../../../test_utils/widget_test_utils.dart';

main() {
  final filter = DocumentFilter.fromSource(fakeDocument.resource.sourceDomain);
  late DiscoveryEngine engine;
  late HiveDocumentFilterRepository repository;
  late FilterDeleteHistory history;
  setUp(() async {
    await setupWidgetTest();
  });

  SourceFilterSettingsManager manager({
    Set<DocumentFilter> dbValues = const {},
    Set<DocumentFilter> historyValues = const {},
    Set<String> engineValues = const {},
  }) {
    repository = di.get();
    repository.saveAll(dbValues);

    final documentFilterUseCase = CrudDocumentFilterUseCase(repository);
    engine = di.get<DiscoveryEngine>();
    for (var e in engineValues) {
      engine.addSourceToExcludedList(e);
    }

    final applyDocumentFilterUseCase =
        ApplyDocumentFilterUseCase(repository, engine);
    history = FilterDeleteHistory();
    for (var e in historyValues) {
      history.add(e);
    }

    return SourceFilterSettingsManager(
        documentFilterUseCase, history, applyDocumentFilterUseCase);
  }

  blocTest<SourceFilterSettingsManager, SourceFilterSettingsState>(
    'WHEN manager just created THEN emit state without any filters',
    build: () => manager(),
    expect: () => [
      const SourceFilterSettingsState(
        filters: {},
      )
    ],
  );

  blocTest<SourceFilterSettingsManager, SourceFilterSettingsState>(
    'WHEN manager inits with db values, they will be shown in the state',
    build: () => manager(dbValues: {filter}),
    skip: 1,
    expect: () => [
      SourceFilterSettingsState(
        filters: {
          filter: true,
        },
      )
    ],
  );

  blocTest<SourceFilterSettingsManager, SourceFilterSettingsState>(
      'WHEN a filter is toggled, it will be removed from db but stays in the history and engine',
      build: () =>
          manager(dbValues: {filter}, engineValues: {filter.filterValue}),
      act: (m) => m.onSourceToggled(filter),
      skip: 1,
      expect: () => [
            SourceFilterSettingsState(
              filters: {
                filter: false,
              },
            )
          ],
      verify: (m) async {
        expect(repository.getAll(), isEmpty);
        expect(history.removedFilters, {filter});
        expect(
          await engine.getExcludedSourcesList(),
          EngineEvent.excludedSourcesListRequestSucceeded({filter.filterValue}),
        );
      });

  blocTest<SourceFilterSettingsManager, SourceFilterSettingsState>(
      'WHEN a filter is toggled twice, db will contain it and history not, engine is not affected',
      build: () =>
          manager(dbValues: {filter}, engineValues: {filter.filterValue}),
      act: (m) {
        m.onSourceToggled(filter);
        m.onSourceToggled(filter);
      },
      skip: 1,
      expect: () => [
            SourceFilterSettingsState(
              filters: {
                filter: true,
              },
            )
          ],
      verify: (m) async {
        expect(repository.getAll(), {filter});
        expect(history.removedFilters, isEmpty);
        expect(
          await engine.getExcludedSourcesList(),
          EngineEvent.excludedSourcesListRequestSucceeded({filter.filterValue}),
        );
      });

  blocTest<SourceFilterSettingsManager, SourceFilterSettingsState>(
      'WHEN a filter is deleted apply will write the change to the engine.',
      build: () =>
          manager(dbValues: {filter}, engineValues: {filter.filterValue}),
      act: (m) async {
        m.onSourceToggled(filter);
        await m.applyChanges();
      },
      skip: 1,
      expect: () => [
            SourceFilterSettingsState(
              filters: {
                filter: false,
              },
            )
          ],
      verify: (m) async {
        expect(repository.getAll(), isEmpty);
        expect(history.removedFilters, {filter});
        expect(
          await engine.getExcludedSourcesList(),
          const EngineEvent.excludedSourcesListRequestSucceeded({}),
        );
      });
}
