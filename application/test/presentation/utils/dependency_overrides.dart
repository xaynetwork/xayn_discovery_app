import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/init_logger_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/log_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import 'fakes.dart';

@Injectable(as: InvokeApiEndpointUseCase)
class TestBingClient extends InvokeApiEndpointUseCase {
  @override
  Stream<ApiEndpointResponse> transaction(Uri param) {
    return Stream.value(ApiEndpointResponse.complete([fakeDocument]));
  }
}

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
class TestDiscoveryEngine implements AppDiscoveryEngine {
  final StreamController<EngineEvent> _onEngineEvent =
      StreamController<EngineEvent>.broadcast();

  void close() {
    _onEngineEvent.close();
  }

  @factoryMethod
  static Future<TestDiscoveryEngine> create() async {
    return TestDiscoveryEngine();
  }

  @override
  Future<EngineEvent> changeConfiguration(
      {Pattern? feedMarket, int? maxItemsPerFeedBatch}) {
    return Future.value(const EngineEvent.clientEventSucceeded());
  }

  @override
  Future<EngineEvent> changeDocumentFeedback(
      {required DocumentId documentId, required DocumentFeedback feedback}) {
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
  Future<EngineEvent> requestFeed() {
    return Future.value(EngineEvent.feedRequestSucceeded([fakeDocument]));
  }

  @override
  Future<EngineEvent> requestNextFeedBatch() {
    return Future.value(EngineEvent.feedRequestSucceeded([fakeDocument]));
  }

  @override
  Future<EngineEvent> resetEngine() {
    return Future.value(const EngineEvent.clientEventSucceeded());
  }

  @override
  Future<EngineEvent> search(String searchTerm) {
    return Future.value(EngineEvent.feedRequestSucceeded([fakeDocument]));
  }

  @override
  void tempAddEvent(EngineEvent event) => _onEngineEvent.add(event);

  @override
  DocumentFeedbackChange? resolveChangeDocumentFeedbackParameters(
      EngineEvent engineEvent) {
    // TODO: implement resolveChangeDocumentFeedbackParameters
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<EngineEvent> send(ClientEvent event) {
    // TODO: implement send
    throw UnimplementedError();
  }
}
