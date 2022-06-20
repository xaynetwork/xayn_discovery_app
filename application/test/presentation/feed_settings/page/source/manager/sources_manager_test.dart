import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_pending_operations.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../../../../../test_utils/utils.dart';

void main() {
  late SourcesManager manager;
  late MockEngineEventsUseCase engineEventsUseCase;
  late SourcesPendingOperations sourcesPendingOperations;
  late StreamController<EngineEvent> eventsController;
  late MockAppDiscoveryEngine engine;

  final defaultExcludedSources = {
    Source('https://www.a.com'),
    Source('https://www.b.com'),
    Source('https://www.c.com'),
  };
  final defaultTrustedSources = {
    Source('https://www.x.com'),
    Source('https://www.y.com'),
    Source('https://www.z.com'),
  };
  final newSource = Source('https://www.new.com');

  addEvent(EngineEvent event) {
    eventsController.add(event);

    return Future.value(event);
  }

  addEventFromSource(
      Invocation invocation, EngineEvent Function(Source source) buildEvent) {
    final source = invocation.positionalArguments.first as Source;
    final event = buildEvent(source);

    eventsController.add(event);

    return Future.value(event);
  }

  setUp(() async {
    sourcesPendingOperations = InMemorySourcesPendingOperations();
    engineEventsUseCase = MockEngineEventsUseCase();
    engine = MockAppDiscoveryEngine();
    eventsController = StreamController<EngineEvent>();

    when(engineEventsUseCase.transaction(any))
        .thenAnswer((_) => eventsController.stream);
    when(engineEventsUseCase.transform(any))
        .thenAnswer((it) => it.positionalArguments.first);
    when(engine.getAvailableSourcesList(any)).thenAnswer(
      (realInvocation) async => addEvent(AvailableSourcesListRequestSucceeded(
        [
          AvailableSource(
              name: realInvocation.positionalArguments.first,
              domain:
                  'https://www.${realInvocation.positionalArguments.first}.com')
        ],
      )),
    );
    when(engine.getExcludedSourcesList()).thenAnswer((_) =>
        addEvent(ExcludedSourcesListRequestSucceeded(defaultExcludedSources)));
    when(engine.getTrustedSourcesList()).thenAnswer((_) =>
        addEvent(TrustedSourcesListRequestSucceeded(defaultTrustedSources)));
    when(engine.addSourceToExcludedList(any)).thenAnswer((it) =>
        addEventFromSource(
            it, (source) => AddExcludedSourceRequestSucceeded(source)));
    when(engine.addSourceToTrustedList(any)).thenAnswer((it) =>
        addEventFromSource(
            it, (source) => AddTrustedSourceRequestSucceeded(source)));
    when(engine.removeSourceFromExcludedList(any)).thenAnswer((it) =>
        addEventFromSource(
            it, (source) => RemoveExcludedSourceRequestSucceeded(source)));
    when(engine.removeSourceFromTrustedList(any)).thenAnswer((it) =>
        addEventFromSource(
            it, (source) => RemoveTrustedSourceRequestSucceeded(source)));
    when(engine.send(any)).thenAnswer((realInvocation) {
      final clientEvent =
          realInvocation.positionalArguments.first as ClientEvent;

      if (clientEvent == const ClientEvent.trustedSourcesListRequested()) {
        return addEvent(
            TrustedSourcesListRequestSucceeded(defaultTrustedSources));
      } else if (clientEvent is ExcludedSourceAdded) {
        return addEvent(AddExcludedSourceRequestSucceeded(clientEvent.source));
      } else if (clientEvent is TrustedSourceAdded) {
        return addEvent(AddTrustedSourceRequestSucceeded(clientEvent.source));
      } else if (clientEvent is ExcludedSourceRemoved) {
        return addEvent(
            RemoveExcludedSourceRequestSucceeded(clientEvent.source));
      } else if (clientEvent is TrustedSourceRemoved) {
        return addEvent(
            RemoveTrustedSourceRequestSucceeded(clientEvent.source));
      }

      return Future.value(realInvocation.positionalArguments.first);
    });

    await configureTestDependencies();

    di.allowReassignment = true;

    di.registerFactory<DiscoveryEngine>(() => engine);

    manager = SourcesManager(engineEventsUseCase, sourcesPendingOperations);
  });

  blocTest<SourcesManager, SourcesState>(
    'WHEN SourcesManager initializes THEN expect excluded and trusted sources to be filled ',
    build: () => manager,
    act: (manager) => manager.init(),
    verify: (manager) => expect(
        manager.state,
        SourcesState(
          excludedSources: defaultExcludedSources,
          trustedSources: defaultTrustedSources,
          jointExcludedSources: defaultExcludedSources,
          jointTrustedSources: defaultTrustedSources,
        )),
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN requesting all sources THEN expect the result in the state ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.getAvailableSourcesList('new');
    },
    verify: (manager) => expect(
        manager.state,
        SourcesState(
          availableSources: {
            AvailableSource(name: 'new', domain: 'https://www.new.com')
          },
          excludedSources: defaultExcludedSources,
          trustedSources: defaultTrustedSources,
          jointExcludedSources: defaultExcludedSources,
          jointTrustedSources: defaultTrustedSources,
        )),
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN adding a pending excluded source THEN expect this entry in the jointExcludedSources ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToExcludedList(newSource);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: defaultTrustedSources,
            jointExcludedSources: {...defaultExcludedSources, newSource},
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.excluded),
          true);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN persisting a pending excluded source THEN expect this entry in the excludedSources as well ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToExcludedList(newSource);
      manager.applyChanges(intervalBetweenOperations: Duration.zero);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: {...defaultExcludedSources, newSource},
            trustedSources: defaultTrustedSources,
            jointExcludedSources: {...defaultExcludedSources, newSource},
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.excluded),
          false);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN adding a pending trusted source THEN expect this entry in the jointTrustedSources ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToTrustedList(newSource);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: defaultTrustedSources,
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: {...defaultTrustedSources, newSource},
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.trusted),
          true);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN persisting a pending trusted source THEN expect this entry in the trustedSources as well ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToTrustedList(newSource);
      manager.applyChanges(intervalBetweenOperations: Duration.zero);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: {...defaultTrustedSources, newSource},
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: {...defaultTrustedSources, newSource},
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.trusted),
          false);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN removing an excluded source THEN expect this entry to become a pending removal ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.removeSourceFromExcludedList(defaultExcludedSources.first);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: defaultTrustedSources,
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingRemoval(
              source: defaultExcludedSources.first, scope: SourceType.excluded),
          true);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN persisting a pending removal of an excluded source THEN expect this entry to become an actual removal ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.removeSourceFromExcludedList(defaultExcludedSources.first);
      manager.applyChanges(intervalBetweenOperations: Duration.zero);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources.toSet()
              ..remove(defaultExcludedSources.first),
            trustedSources: defaultTrustedSources,
            jointExcludedSources: defaultExcludedSources.toSet()
              ..remove(defaultExcludedSources.first),
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingRemoval(
              source: defaultExcludedSources.first, scope: SourceType.excluded),
          false);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN removing a trusted source THEN expect this entry to become a pending removal ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.removeSourceFromTrustedList(defaultTrustedSources.first);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: defaultTrustedSources,
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingRemoval(
              source: defaultTrustedSources.first, scope: SourceType.trusted),
          true);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN persisting a pending removal of a trusted source THEN expect this entry to become an actual removal ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.removeSourceFromTrustedList(defaultTrustedSources.first);
      manager.applyChanges(intervalBetweenOperations: Duration.zero);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: defaultTrustedSources.toSet()
              ..remove(defaultTrustedSources.first),
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: defaultTrustedSources.toSet()
              ..remove(defaultTrustedSources.first),
          ));

      expect(
          manager.isPendingRemoval(
              source: defaultTrustedSources.first, scope: SourceType.trusted),
          false);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN adding a pending excluded source and then undoing it THEN expect the state to reflect this ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToExcludedList(newSource);
      manager.removePendingSourceOperation(newSource);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: defaultTrustedSources,
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.excluded),
          false);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN adding a pending trusted source and then undoing it THEN expect the state to reflect this ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToTrustedList(newSource);
      manager.removePendingSourceOperation(newSource);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: defaultTrustedSources,
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.excluded),
          false);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN adding a pending excluded source and then undoing it AFTER applyChanges THEN expect nothing changes ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToExcludedList(newSource);
      manager.applyChanges(intervalBetweenOperations: Duration.zero);
      manager.removePendingSourceOperation(newSource);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: {...defaultExcludedSources, newSource},
            trustedSources: defaultTrustedSources,
            jointExcludedSources: {...defaultExcludedSources, newSource},
            jointTrustedSources: defaultTrustedSources,
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.excluded),
          false);
    },
  );

  blocTest<SourcesManager, SourcesState>(
    'WHEN adding a pending trusted source and then undoing it AFTER applyChanges THEN expect nothing changes ',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.addSourceToTrustedList(newSource);
      manager.applyChanges(intervalBetweenOperations: Duration.zero);
      manager.removePendingSourceOperation(newSource);
    },
    verify: (manager) {
      expect(
          manager.state,
          SourcesState(
            excludedSources: defaultExcludedSources,
            trustedSources: {...defaultTrustedSources, newSource},
            jointExcludedSources: defaultExcludedSources,
            jointTrustedSources: {...defaultTrustedSources, newSource},
          ));

      expect(
          manager.isPendingAddition(
              source: newSource, scope: SourceType.excluded),
          false);
    },
  );
}
