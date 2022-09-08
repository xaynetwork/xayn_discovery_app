import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/article/article_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/constants/analytics_constants.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/decode_article_use_case.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';

@injectable
class RetrieveDeepLinkDataUseCase
    extends UseCase<DeepLinkResult, DeepLinkData> {
  final DecodeArticleUseCase _decodeArticleUseCase;

  RetrieveDeepLinkDataUseCase(this._decodeArticleUseCase);

  @override
  Stream<DeepLinkData> transaction(DeepLinkResult param) async* {
    final deepLinkName = param.deepLink?.deepLinkValue;
    ArticleData? articleData;

    /// Check if the deep link is the one used for sharing a document
    if (deepLinkName == PageName.cardDetails.name) {
      /// If yes, retrieve the encoded document from the deepLink and decode it
      final encodedDocument = param.deepLink!
          .getStringValue(AnalyticsConstants.articleLinkParamName);

      if (encodedDocument != null) {
        articleData = await _decodeArticleUseCase.singleOutput(encodedDocument);
      }

      yield DeepLinkData.fromValue(
          DeepLinkValue.cardDetailsFromDocument, articleData?.document);
      return;
    }
    final deepLinkValue = DeepLinkValue.values.firstWhere(
      (it) => it.name == deepLinkName,
      orElse: () => DeepLinkValue.none,
    );
    yield DeepLinkData.fromValue(deepLinkValue);
  }
}
