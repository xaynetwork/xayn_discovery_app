import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/marketing_analytics_service.dart';
import 'package:xayn_discovery_app/domain/model/analytics/generate_invite_link_result.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/encode_document_use_case.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class ShareDocumentUseCase extends UseCase<Document, Document> {
  final MarketingAnalyticsService _marketingAnalyticsService;
  final EncodeDocumentUseCase _encodeDocumentUseCase;
  final ShareUriUseCase _shareUriUseCase;

  ShareDocumentUseCase(
    this._marketingAnalyticsService,
    this._encodeDocumentUseCase,
    this._shareUriUseCase,
  );

  @override
  Stream<Document> transaction(Document param) async* {
    final encodedDocument = await _encodeDocumentUseCase.singleOutput(param);
    final generateInviteLinkResult = await _marketingAnalyticsService
        .generateLinkForSharingDocument(encodedDocument: encodedDocument);

    late String url;

    if (generateInviteLinkResult is GenerateInviteLinkSuccess) {
      url = generateInviteLinkResult.userInviteUrl;
    } else {
      /// If the generation of the deep link didn't succeed,
      /// then share just the url of the document
      url = param.resource.url.toString();
    }
    await _shareUriUseCase.singleOutput(Uri.parse(url));
    yield param;
  }
}
