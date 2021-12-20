import 'dart:typed_data';

class CacheManagerEvent {
  final Uri originalUri;
  final double progress;
  final Uint8List? bytes;
  final Map<String, String>? cookies;

  const CacheManagerEvent({
    required this.originalUri,
    required this.progress,
    this.bytes,
    this.cookies,
  });

  const CacheManagerEvent.progress(this.originalUri, this.progress)
      : bytes = null,
        cookies = null;

  const CacheManagerEvent.completed(this.originalUri, this.bytes)
      : progress = 1.0,
        cookies = null;

  const CacheManagerEvent.direct(this.originalUri, this.cookies)
      : bytes = null,
        progress = 1.0;
}

class CacheManagerError extends Error {}
