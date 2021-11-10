import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

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

    return news.cast<Map>().map((it) {
      String? imageUrl;

      if (it.containsKey('image')) {
        final image = it['image'] as Map<String, dynamic>;

        if (image.containsKey('contentUrl')) {
          imageUrl = image['contentUrl'] as String;
        }
      }

      return Document(
        documentId: const DocumentId(key: ''),
        webResource: WebResource(
          displayUrl: imageUrl != null
              ? Uri.parse(imageUrl)
              : Uri.parse('https://www.xayn.com'),
          url: Uri.parse(it['url'] as String? ?? ''),
          snippet: it['description'] as String? ?? '',
          title: it['name'] as String? ?? '',
        ),
        nonPersonalizedRank: 0,
        personalizedRank: 0,
      );
    }).toList(growable: false);
  }
}

/// A standalone Function which can be used in combination with [compute].
Map<String, dynamic> _decodeJson(String raw) =>
    const JsonDecoder().convert(raw);
