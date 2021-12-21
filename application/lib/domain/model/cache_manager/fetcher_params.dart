import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetcher_params.freezed.dart';

/// The input of [ProxyUriUseCase]
@freezed
class FetcherParams with _$FetcherParams {
  /// Creates new parameters for fetching an image via a proxy.
  factory FetcherParams({
    /// The original image uri
    required Uri uri,

    /// The requested image width
    int? width,

    /// The requested image height
    int? height,

    /// fit type, eg: cover
    String? fit,

    /// blur amount, eg: 5
    int? blur,

    /// rotation in degrees
    int? rotation,

    /// image tint overlay eg: red
    String? tint,

    /// whether or not we can use our image fetcher proxy
    @Default(true) bool canUseProxy,
  }) = _FetcherParams;
}
