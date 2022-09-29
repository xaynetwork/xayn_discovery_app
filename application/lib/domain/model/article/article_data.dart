import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'article_data.freezed.dart';
part 'article_data.g.dart';

@freezed
class ArticleData with _$ArticleData {
  factory ArticleData({
    required Document document,
    String? timeAgoPublished,
    String? timeToRead,
    String? author,
    String? providerName,
    String? providerFavIcon,
  }) = _ArticleData;

  factory ArticleData.fromJson(Map<String, dynamic> json) =>
      _$ArticleDataFromJson(json);
}
