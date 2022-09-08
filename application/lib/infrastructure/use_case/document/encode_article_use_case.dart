import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/article/article_data.dart';

@injectable
class EncodeArticleUseCase extends UseCase<ArticleData, String> {
  @override
  Stream<String> transaction(ArticleData param) async* {
    final encodedArticleData = base64.encode(
      utf8.encode(
        json.encode(
          param.toJson(),
        ),
      ),
    );
    yield encodedArticleData;
  }
}
