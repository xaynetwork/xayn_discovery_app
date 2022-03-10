import 'dart:async';

import 'package:http_client/http_client.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/request_client/client.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/init_logger_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/log_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import 'fakes.dart';

@Injectable(as: ConnectivityUriUseCase)
class AlwaysConnectedConnectivityUseCase extends ConnectivityUriUseCase {
  @override
  Stream<Uri> transaction(Uri param) {
    return Stream.value(param);
  }
}

@Singleton(as: InitLoggerUseCase)
class JustLogToConsoleUseCase extends InitLoggerUseCase {
  JustLogToConsoleUseCase(FileHandler fileHandler, LoggerHandler loggerHandler)
      : super(fileHandler, loggerHandler);

  @override
  Stream<None> transaction(param) async* {
    initLogger(output: ConsoleOutput());
  }
}

@Singleton(as: LogManager)
class TestLogManager extends LogManager {
  TestLogManager(InitLoggerUseCase initLoggerUseCase)
      : super(initLoggerUseCase);
}

@LazySingleton(as: DiscoveryEngine)
class TestDiscoveryEngine with AsyncInitMixin implements AppDiscoveryEngine {
  final StreamController<EngineEvent> _onEngineEvent =
      StreamController<EngineEvent>.broadcast();

  void close() {
    _onEngineEvent.close();
  }

  TestDiscoveryEngine();

  @override
  Future<EngineEvent> changeConfiguration({
    FeedMarkets? feedMarkets,
    int? maxItemsPerFeedBatch,
    int? maxItemsPerSearchBatch,
  }) {
    return Future.value(const EngineEvent.clientEventSucceeded());
  }

  @override
  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) {
    return Future.value(const EngineEvent.clientEventSucceeded());
  }

  @override
  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) {
    return Future.value(const EngineEvent.clientEventSucceeded());
  }

  @override
  Stream<EngineEvent> get engineEvents => _onEngineEvent.stream;

  @override
  Future<EngineEvent> logDocumentTime(
      {required DocumentId documentId,
      required DocumentViewMode mode,
      required int seconds}) {
    return Future.value(const EngineEvent.clientEventSucceeded());
  }

  @override
  Future<EngineEvent> restoreFeed() {
    return Future.value(EngineEvent.restoreFeedSucceeded([fakeDocument]));
  }

  @override
  Future<EngineEvent> requestNextFeedBatch() {
    return Future.value(EngineEvent.restoreFeedSucceeded([fakeDocument]));
  }

  @override
  void tempAddEvent(EngineEvent event) => _onEngineEvent.add(event);

  @override
  Future<void> dispose() async {}

  @override
  Future<EngineEvent> send(ClientEvent event) {
    // TODO: implement send
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  // TODO: implement engineInputEventsLog
  Stream<String> get engineInputEventsLog => throw UnimplementedError();

  @override
  Future<EngineEvent> updateMarkets() {
    // TODO: implement maybeUpdateMarkets
    throw UnimplementedError();
  }

  @override
  Future<bool> areMarketsOutdated() {
    // TODO: implement willUpdateMarkets
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> closeSearch() {
    // TODO: implement closeSearch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestNextSearchBatch() {
    // TODO: implement requestNextSearchBatch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> requestSearch({
    required String queryTerm,
    required FeedMarket market,
  }) {
    // TODO: implement requestSearch
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> restoreSearch() {
    // TODO: implement restoreSearch
    throw UnimplementedError();
  }
}

@LazySingleton(as: AnalyticsService)
class TestAnalyticsService implements AnalyticsService {
  TestAnalyticsService();

  @override
  Future<void> flush() async {}

  @override
  Future<void> send(AnalyticsEvent event) async {}
}

@Injectable(as: Client)
class FakeHttpClient extends Client {
  @factoryMethod
  factory FakeHttpClient.always404() =>
      FakeHttpClient((request) async => http.Response(
          404, 'FakeResponse: Resource not found.', http.Headers(), null));

  FakeHttpClient(this.handler);
  final Future<http.Response> Function(http.Request request) handler;

  @override
  Future close({bool force = false}) async {
    // Do nothing
  }

  @override
  Future<http.Response> send(http.Request request) => handler(request);
}

@Injectable(as: DirectUriUseCase)
class TestableDirectUriUseCase extends DirectUriUseCase {
  TestableDirectUriUseCase(
    Client client,
  ) : super(
          client: client,
          headers: const {},
          cacheManager: createFakeImageCacheManager(),
        );
}
