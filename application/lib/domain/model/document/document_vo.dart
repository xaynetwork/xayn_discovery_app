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
  final String publishedDatePrecision;
  final String cleanUrl;
  final String? cleanRss;
  final bool isRss;
  final int articleLength;
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
        publishedDatePrecision = jsonRaw['published_date_precision'],
        cleanUrl = jsonRaw['clean_url'],
        cleanRss = jsonRaw['clean_rss'],
        isRss = jsonRaw['is_rss'],
        articleLength = jsonRaw['article_length'],
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

/*
I/flutter ( 5562): key: title, type: String value: Like ‘Bridgerton'? Wait till you catch ‘Mr. Malcolm's List'
I/flutter ( 5562): key: author, type: String value: LINDSEY BAHR
I/flutter ( 5562): key: published_date, type: String value: 2022-06-30 19:46:29
I/flutter ( 5562): key: published_date_precision, type: String value: full
I/flutter ( 5562): key: link, type: String value: https://www.sfgate.com/entertainment/article/Like-Bridgerton-Wait-till-you-catch-Mr-17277430.php
I/flutter ( 5562): key: clean_url, type: String value: sfgate.com
I/flutter ( 5562): key: clean_rss, type: Null value: null
I/flutter ( 5562): key: is_rss, type: bool value: false
I/flutter ( 5562): key: excerpt, type: String value: Years before 'Bridgerton' and the Regency-era fashion moment it helped inspire,...
I/flutter ( 5562): key: article_length, type: int value: 4801
I/flutter ( 5562): key: rank, type: int value: 410
I/flutter ( 5562): key: topic, type: String value: entertainment
I/flutter ( 5562): key: country, type: String value: US
I/flutter ( 5562): key: language, type: String value: en
I/flutter ( 5562): key: media, type: String value: https://s.hdnux.com/photos/01/26/33/15/22655811/3/rawImage.jpg
I/flutter ( 5562): key: media_info, type: _InternalLinkedHashMap<String, dynamic> value: {size_in_bytes: 0, width: 0, height: 0}
I/flutter ( 5562): key: feedparser_metadata, type: Null value: null
I/flutter ( 5562): key: _score, type: double value: 33.201668
I/flutter ( 5562): key: _id, type: String value: b6da751b145c969a3aeb204c51de32fc
 */
