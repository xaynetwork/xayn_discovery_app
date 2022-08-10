import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/constants/analytics_constants.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/decode_document_use_case.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_data.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class RetrieveDeepLinkDataUseCase
    extends UseCase<DeepLinkResult, DeepLinkData> {
  final DecodeDocumentUseCase _decodeDocumentUseCase;

  RetrieveDeepLinkDataUseCase(this._decodeDocumentUseCase);

  @override
  Stream<DeepLinkData> transaction(DeepLinkResult param) async* {
    final deepLinkName = param.deepLink?.deepLinkValue;
    Document? document;

    /// Check if the deep link is the one used for sharing a document
    if (deepLinkName == PageName.cardDetails.name) {
      /// If yes, retrieve the encoded document from the deepLink and decode it
      final encodedDocument = param.deepLink!
          .getStringValue(AnalyticsConstants.documentLinkParamName);

      if (encodedDocument != null) {
        document = await _decodeDocumentUseCase.singleOutput(encodedDocument);
      }

      yield DeepLinkData.fromValue(
          DeepLinkValue.cardDetailsFromDocument, document);
      return;
    }
    final deepLinkValue = DeepLinkValue.values.firstWhere(
      (it) => it.name == deepLinkName,
      orElse: () => DeepLinkValue.none,
    );
    yield DeepLinkData.fromValue(deepLinkValue);
  }
}
