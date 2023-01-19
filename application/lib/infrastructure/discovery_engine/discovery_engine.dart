import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';

import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/next_feed_batch_request_failed.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/next_feed_batch_request_succeeded.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/restore_feed_failed.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/restore_feed_succeeded.dart';
import 'package:xayn_discovery_app/domain/model/legacy/mappers/document_response_codec.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

@singleton
class DiscoveryEngine {
  final tokenHeaderName = 'authorizationToken';
  final String userId;
  final Uri endpoint = Uri.parse(Env.searchApiBaseUrl);
  final String token = Env.searchApiSecretKey;
  final http.Client client = http.Client();
  final StreamController<EngineEvent> _engineEventsController =
      StreamController<EngineEvent>();
  late final _restoredItems = _restoreFeed();

  DiscoveryEngine._(this.userId);

  factory DiscoveryEngine() {
    final userId = const Uuid().v4();

    return DiscoveryEngine._(userId);
  }

  Stream<EngineEvent> get engineEvents => _engineEventsController.stream;

  static Future<List<Document>> _restoreFeed() async {
    final random = Random();
    const decoder = DocumentResponseDecoder();

    final json = await rootBundle.loadString('assets/data_set.json');
    final decoded = const JsonDecoder().convert(json) as List;
    final rndData = List<Map>.generate(
        2, (_) => decoded[random.nextInt(decoded.length)] as Map);

    return rndData
        .cast<Map<String, dynamic>>()
        .map(decoder.convert)
        .toList(growable: false);
  }

  Future<EngineEvent> restoreFeed() async {
    late final EngineEvent engineEvent;

    try {
      engineEvent = RestoreFeedSucceeded(await _restoredItems);
    } catch (e, s) {
      logger.e('restoreFeed exception: $e - $s');

      engineEvent = const RestoreFeedFailed();
    }

    _engineEventsController.add(engineEvent);

    return engineEvent;
  }

  Future<EngineEvent> requestNextFeedBatch() async {
    const decoder = DocumentResponseDecoder();
    final url = endpoint.resolve('default/users/$userId/personalized_documents')
      ..replace(queryParameters: const {'count': '2'});
    final response = await client.get(url, headers: {tokenHeaderName: token});

    if (response.statusCode != 200) {
      logger.e(
          '[${response.statusCode}] requestNextFeedBatch failed\n${response.body}');

      final engineEvent = response.statusCode == 409
          ? const NextFeedBatchRequestSucceeded([])
          : const NextFeedBatchRequestFailed();

      _engineEventsController.add(engineEvent);

      return engineEvent;
    }

    final json = const JsonDecoder().convert(response.body);
    final documents = json['documents'] as List;
    final items = documents
        .cast<Map<String, dynamic>>()
        .map(decoder.convert)
        .toList(growable: false);
    final engineEvent = NextFeedBatchRequestSucceeded(items);

    _engineEventsController.add(engineEvent);

    return engineEvent;
  }

  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) async {
    final url = endpoint.resolve('default/users/$userId/interactions');
    final response = await client.patch(url,
        headers: {tokenHeaderName: token},
        body: const JsonEncoder().convert({
          'documents': [documentId.value],
        }));

    if (response.statusCode == 204) {
      logger.i('patched interaction for documentId: $documentId');
    } else {
      logger.e(
          '[${response.statusCode}] could not patch interaction for documentId: $documentId\n${response.body}');
    }

    const engineEvent = NoneEvent();

    _engineEventsController.add(engineEvent);

    return engineEvent;
  }

  Future<EngineEvent> logDocumentTime({
    required DocumentId documentId,
    required int seconds,
    required DocumentViewMode mode,
  }) async =>
      const NoneEvent();
}
