import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/article/article_data.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/domain/model/analytics/generate_invite_link_result.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/encode_article_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/time_ago.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class ShareArticleUseCase extends UseCase<ShareArticleUseCaseIn, ArticleData> {
  final MarketingAnalyticsService _marketingAnalyticsService;
  final EncodeArticleUseCase _encodeArticleUseCase;
  final ShareUriUseCase _shareUriUseCase;

  ShareArticleUseCase(
    this._marketingAnalyticsService,
    this._encodeArticleUseCase,
    this._shareUriUseCase,
  );

  @override
  Stream<ArticleData> transaction(ShareArticleUseCaseIn param) async* {
    final document = param.document;
    final processedDocument = param.processedDocument;
    final documentProvider = processedDocument?.getProvider(document.resource);
    final articleData = ArticleData(
      document: document,
      timeAgoPublished: timeAgo(
        document.resource.datePublished,
        DateFormat.yMMMMd(),
      ),
      timeToRead: processedDocument?.timeToRead,
      author: processedDocument?.processHtmlResult.author,
      providerName: documentProvider?.name,
      providerFavIcon: documentProvider?.favicon,
    );

    final encodedArticleData =
        await _encodeArticleUseCase.singleOutput(articleData);
    final generateInviteLinkResult = await _marketingAnalyticsService
        .generateLinkForSharingArticle(encodedArticleData: encodedArticleData);

    late String url;

    if (generateInviteLinkResult is GenerateInviteLinkSuccess) {
      url = generateInviteLinkResult.userInviteUrl;
    } else {
      /// If the generation of the deep link didn't succeed,
      /// then share just the url of the document
      url = param.document.resource.url.toString();
    }
    await _shareUriUseCase.singleOutput(Uri.parse(url));
    yield articleData;
  }
}

class ShareArticleUseCaseIn {
  final Document document;
  final ProcessedDocument? processedDocument;

  ShareArticleUseCaseIn({
    required this.document,
    this.processedDocument,
  });
}
