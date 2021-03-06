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
  final String? detectedLanguage;
  final bool? isGibberish;

  const ProcessedDocument({
    required this.processHtmlResult,
    required this.timeToRead,
    this.detectedLanguage,
    this.isGibberish,
  });

  DocumentProvider getProvider(NewsResource resource) {
    final link = processHtmlResult.favicon;
    final favIcon = link ?? '/favicon.ico';

    return DocumentProvider(
      name: processHtmlResult.metadata?.siteName ?? resource.sourceDomain.value,
      favicon: resource.url.resolve(favIcon).toString(),
    );
  }
}
