import 'dart:convert';

import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/news_resource.dart';
import 'package:xayn_discovery_app/domain/model/legacy/source.dart';
import 'package:xayn_discovery_app/domain/model/legacy/stack_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';

class DocumentResponseCodec extends Codec<Document, Map<String, dynamic>> {
  const DocumentResponseCodec();

  @override
  Converter<Map<String, dynamic>, Document> get decoder =>
      const DocumentResponseDecoder();

  @override
  Converter<Document, Map<String, dynamic>> get encoder =>
      const DocumentResponseEncoder();
}

class DocumentResponseDecoder
    extends Converter<Map<String, dynamic>, Document> {
  const DocumentResponseDecoder();

  @override
  Document convert(Map<String, dynamic> input) {
    final properties = input['properties'] as Map<String, dynamic>? ?? const {};
    final today = DateTime.now();

    return Document(
        documentId: DocumentId.fromValue(input['id'] as String),
        userReaction: UserReaction.neutral,
        resource: NewsResource(
          title: properties['title'] as String? ?? '',
          snippet: input['snippet'] as String,
          url: Uri.parse(properties['link'] as String? ?? ''),
          sourceDomain: const Source(''),
          image: Uri.parse(properties['image'] as String? ?? ''),
          datePublished: properties.containsKey('published_date')
              ? DateTime.parse(
                  properties['published_date'] as String? ?? '2023-01-01')
              : today,
          country: properties['country'] as String? ?? '',
          language: properties['language'] as String? ?? '',
          rank: -1,
          score: .0,
          topic: properties['topic'] as String? ?? '',
        ),
        stackId: const StackId.nil());
  }
}

class DocumentResponseEncoder
    extends Converter<Document, Map<String, dynamic>> {
  const DocumentResponseEncoder();

  @override
  Map<String, dynamic> convert(Document input) {
    throw UnimplementedError();
  }
}
