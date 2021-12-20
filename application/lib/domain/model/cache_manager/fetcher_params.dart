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

  FetcherParams copyWith({
    Uri? uri,
    int? width,
    int? height,
    String? fit,
    int? blur,
    int? rotation,
    String? tint,
    Map<String, String>? cookies,
  }) =>
      FetcherParams(
        uri: uri ?? this.uri,
        width: width ?? this.width,
        height: height ?? this.height,
        fit: fit ?? this.fit,
        blur: blur ?? this.blur,
        rotation: rotation ?? this.rotation,
        tint: tint ?? this.tint,
        cookies: cookies ?? this.cookies,
      );
}
