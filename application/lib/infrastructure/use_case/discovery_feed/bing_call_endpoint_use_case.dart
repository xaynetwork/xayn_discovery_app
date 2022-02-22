import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Mock implementation,
/// This will be deprecated once the real discovery engine is available.
///
/// An implementation of [InvokeApiEndpointUseCase] which uses the Bing news api
/// to fetch results.
@Injectable(as: InvokeApiEndpointUseCase)
class InvokeBingUseCase extends InvokeApiEndpointUseCase {
  InvokeBingUseCase();

  @override
  Stream<ApiEndpointResponse> transaction(Uri param) async* {
    yield const ApiEndpointResponse.incomplete();

    final response = await http.get(param,
        headers: const {'Authorization': 'Bearer ${Env.searchApiSecretKey}'});

    if (response.statusCode != 200) {
      throw ApiEndpointError(
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final data = await compute(_decodeJson, response.body);

    yield ApiEndpointResponse.complete(_deserialize(data));
  }

  List<Document> _deserialize(Map<String, dynamic> data) {
    const emptyNewsMap = <String, dynamic>{'value': []};
    final newsMap = data['news'] as Map<String, dynamic>?;
    final news = (newsMap ?? emptyNewsMap)['value'] as List;
    final documents = <Document>[];

    for (var it in news.cast<Map>()) {
      String? imageUrl;

      if (it.containsKey('image')) {
        final image = it['image'] as Map<String, dynamic>;

        if (image.containsKey('contentUrl')) {
          imageUrl = image['contentUrl'] as String;
        }
      }

      final document = Document(
        documentId: DocumentId(),
        resource: NewsResource(
          thumbnail: imageUrl != null ? Uri.parse(imageUrl) : Uri.base,
          url: Uri.parse(it['url'] as String? ?? ''),
          snippet: it['description'] as String? ?? '',
          title: it['name'] as String? ?? '',
          datePublished: DateTime.parse(it['datePublished'] as String),
          country: 'US',
          language: 'en-US',
          rank: -1,
          score: .0,
          sourceUrl: Uri.parse(it['url'] as String? ?? ''),
          topic: 'topic',
        ),
        userReaction: UserReaction.neutral,
        batchIndex: -1,
      );

      documents.add(document);
    }

    return documents;
  }
}

/// A standalone Function which can be used in combination with [compute].
Map<String, dynamic> _decodeJson(String raw) =>
    const JsonDecoder().convert(raw);
