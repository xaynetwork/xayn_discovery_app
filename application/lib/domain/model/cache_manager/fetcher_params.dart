/// The input of [ProxyUriUseCase]
class FetcherParams {
  /// The original image uri
  final Uri uri;

  /// The requested image width
  final int? width;

  /// The requested image height
  final int? height;

  /// fit type, eg: cover
  final String? fit;

  /// blur amount, eg: 5
  final int? blur;

  /// rotation in degrees
  final int? rotation;

  /// image tint overlay eg: red
  final String? tint;

  final Map<String, String>? cookies;

  /// Creates new parameters for fetching an image via a proxy.
  const FetcherParams({
    required this.uri,
    this.width,
    this.height,
    this.fit,
    this.blur,
    this.rotation,
    this.tint,
    this.cookies,
  });

  FetcherParams copyWithUri(Uri uri) => FetcherParams(
        uri: uri,
        width: width,
        height: height,
        fit: fit,
        blur: blur,
        rotation: rotation,
        tint: tint,
        cookies: cookies,
      );

  FetcherParams copyWithCookies(Map<String, String> cookies) => FetcherParams(
        uri: uri,
        width: width,
        height: height,
        fit: fit,
        blur: blur,
        rotation: rotation,
        tint: tint,
        cookies: cookies,
      );
}
