import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@singleton
class HostedDocumentMapper extends Mapper<Map<String, dynamic>, Document> {
  const HostedDocumentMapper();

  @override
  Document map(Map<String, dynamic> input) {
    return Document(
      documentId:
          DocumentId.fromString(input[HostedDocumentMapperFields.id] as String),
      stackId: StackId.nil(),
      userReaction: UserReaction.neutral,
      resource: NewsResource(
        rank: input[HostedDocumentMapperFields.rank] as int,
        title: input[HostedDocumentMapperFields.title] as String,
        image: input[HostedDocumentMapperFields.media] != null
            ? Uri.parse(input[HostedDocumentMapperFields.media] as String)
            : null,
        url: Uri.parse(input[HostedDocumentMapperFields.link] as String),
        topic: input[HostedDocumentMapperFields.topic] as String,
        score: input[HostedDocumentMapperFields.score] as double?,
        language: input[HostedDocumentMapperFields.language] as String,
        country: input[HostedDocumentMapperFields.country] as String,
        datePublished: _parseDateTime(
            input[HostedDocumentMapperFields.publishedDate] as String?),
        snippet: input[HostedDocumentMapperFields.description] as String,
        sourceDomain:
            Source(input[HostedDocumentMapperFields.cleanUrl] as String),
      ),
    );
  }

  DateTime _parseDateTime(String? input) {
    var date = DateTime.now();

    if (input == null) return date;

    final formatterA = DateFormat('yyyy-MM-dd hh:mm:ss'),
        formatterB = DateFormat('yyyy-MM-dd');

    try {
      date = formatterA.parse(input);
    } catch (e) {
      date = formatterB.parse(input);
    }

    return date;
  }
}

abstract class HostedDocumentMapperFields {
  const HostedDocumentMapperFields._();

  static const String id = 'id';
  static const String rank = 'rank';
  static const String title = 'title';
  static const String media = 'media';
  static const String link = 'link';
  static const String topic = 'topic';
  static const String score = '_score';
  static const String language = 'language';
  static const String country = 'country';
  static const String publishedDate = 'published_date';
  static const String description = 'description';
  static const String cleanUrl = 'clean_url';
}
