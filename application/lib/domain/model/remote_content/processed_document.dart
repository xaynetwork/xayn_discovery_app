import 'package:flutter/foundation.dart';
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
}
