import 'package:flutter/foundation.dart';

@immutable
class DocumentVO implements Comparable {
  final Map<String, dynamic> jsonRaw;
  final String id;
  final String title;
  final String? author;
  final String? excerpt;
  final String topic;
  final String country;
  final String language;
  final DateTime publishedDate;
  final int rank;
  final Uri uri;
  final Uri? mediaUri;
  final double score;

  @override
  bool operator ==(Object other) {
    if (other is DocumentVO) return hashCode == other.hashCode;

    return false;
  }

  @override
  int get hashCode => id.hashCode;

  DocumentVO.fromJson(this.jsonRaw)
      : id = jsonRaw['_id'],
        title = jsonRaw['title'],
        author = jsonRaw['author'],
        excerpt = jsonRaw['excerpt'],
        topic = jsonRaw['topic'],
        country = jsonRaw['country'],
        language = jsonRaw['language'],
        publishedDate = DateTime.parse(jsonRaw['published_date']),
        rank = jsonRaw['rank'],
        uri = Uri.parse(jsonRaw['link']),
        mediaUri =
            jsonRaw['media'] != null ? Uri.parse(jsonRaw['media']!) : null,
        score = jsonRaw['_score'];

  @override
  int compareTo(other) {
    if (other is DocumentVO) return other.score.compareTo(score);

    return 0;
  }
}
