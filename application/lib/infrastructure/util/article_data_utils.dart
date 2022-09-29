import 'dart:convert';

import 'package:xayn_discovery_app/domain/model/article/article_data.dart';

class ArticleDataUtils {
  static String encodeArticleData(ArticleData articleData) => base64.encode(
        utf8.encode(
          json.encode(
            articleData.toJson(),
          ),
        ),
      );

  static ArticleData decodeArticleData(String encodedArticleData) =>
      ArticleData.fromJson(
        json.decode(
          utf8.decode(
            base64.decode(encodedArticleData),
          ),
        ),
      );
}
