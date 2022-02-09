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
        webResource: WebResource(
          displayUrl: imageUrl != null ? Uri.parse(imageUrl) : Uri.base,
          url: Uri.parse(it['url'] as String? ?? ''),
          snippet: it['description'] as String? ?? '',
          title: it['name'] as String? ?? '',
          datePublished: DateTime.parse(it['datePublished'] as String),
          provider: getProvider(it),
        ),
        isActive: true,
        feedback: DocumentFeedback.neutral,
        nonPersonalizedRank: 0,
        personalizedRank: 0,
      );

      documents.add(document);
    }

    return documents;
  }
}

WebResourceProvider? getProvider(Map<dynamic, dynamic> map) {
  if (!map.containsKey('provider')) return null;

  String? providerName;
  String? providerLogoUrl;

  try {
    providerName = map['provider'][0]['name'] as String?;
    providerLogoUrl =
        map['provider'][0]['image']['thumbnail']['contentUrl'] as String?;
    // ignore: empty_catches
  } catch (e) {} //TODO: add logger call

  return providerName != null
      ? WebResourceProvider(
          name: providerName,
          thumbnail: providerLogoUrl == null
              ? null
              : Uri.parse('$providerLogoUrl?w=64'),
        )
      : null;
}

/// A standalone Function which can be used in combination with [compute].
Map<String, dynamic> _decodeJson(String raw) =>
    const JsonDecoder().convert(raw);
