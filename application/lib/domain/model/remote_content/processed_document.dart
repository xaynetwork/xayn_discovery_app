import 'package:flutter/foundation.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';
import 'package:xayn_readability/xayn_readability.dart';

/// Represents a document that was:
/// - fully loaded and parsed into reader mode
/// - received post-processing and has extra metadata
///
/// This object is the main data source for feed cards.
@immutable
class ProcessedDocument {
  final ProcessHtmlResult processHtmlResult;
  final String timeToRead;

  const ProcessedDocument({
    required this.processHtmlResult,
    required this.timeToRead,
  });

  DocumentProvider getProvider(NewsResource resource) {
    var favicon = resource.url.resolve('/favicon.ico');

    final link = processHtmlResult.favicon;

    if (link != null) favicon = Uri.parse(link);

    return DocumentProvider(
      name: processHtmlResult.metadata?.siteName ?? resource.url.host,
      favicon: favicon.toString(),
    );
  }
}
