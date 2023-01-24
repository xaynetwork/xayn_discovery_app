import 'package:xayn_discovery_app/domain/model/legacy/source.dart';

class NewsResource {
  final String title;
  final String snippet;
  final Uri url;
  final Source sourceDomain;
  final Uri? image;
  final DateTime datePublished;
  final String country;
  final String language;
  final int rank;
  final double score;
  final String topic;

  const NewsResource({
    required this.title,
    required this.snippet,
    required this.url,
    required this.sourceDomain,
    required this.image,
    required this.datePublished,
    required this.country,
    required this.language,
    required this.rank,
    required this.score,
    required this.topic,
  });

  factory NewsResource.fromJson(Map<String, dynamic> json) => NewsResource(
        title: json['title'],
        snippet: json['snippet'],
        url: Uri.parse(json['url']),
        sourceDomain: Source(json['sourceDomain']),
        image: json.containsKey('image') ? Uri.parse(json['image']) : null,
        datePublished:
            DateTime.fromMillisecondsSinceEpoch(json['datePublished']),
        country: json['country'],
        language: json['language'],
        rank: json['rank'],
        score: json['score'],
        topic: json['topic'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'snippet': snippet,
        'url': '$url',
        'sourceDomain': sourceDomain.value,
        'image': '$image',
        'datePublished': datePublished.millisecondsSinceEpoch,
        'country': country,
        'language': language,
        'rank': rank,
        'score': score,
        'topic': topic,
      };
}
