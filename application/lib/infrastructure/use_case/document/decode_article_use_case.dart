import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/article/article_data.dart';

@injectable
class DecodeArticleUseCase extends UseCase<String, ArticleData> {
  @override
  Stream<ArticleData> transaction(String param) async* {
    final decodedDocument = ArticleData.fromJson(
      json.decode(
        utf8.decode(
          base64.decode(param),
        ),
      ),
    );
    yield decodedDocument;
  }
}
