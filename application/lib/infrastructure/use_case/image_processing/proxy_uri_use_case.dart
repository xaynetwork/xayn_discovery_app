import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

/// A [UseCase] which takes a proxy url [fetcherUrl], then appends all
/// properties from [FetcherParams] as query parameters.
@injectable
class ProxyUriUseCase extends UseCase<FetcherParams, Uri> {
  /// The proxy url
  /// Example: "https://fetch.me"
  final String fetcherUrl;

  /// Creates a new proxy url use case.
  ProxyUriUseCase({required this.fetcherUrl});

  @factoryMethod
  ProxyUriUseCase.fetcherUrlFromEnv() : fetcherUrl = Env.imageFetcherUrl;

  @override
  Stream<Uri> transaction(FetcherParams param) async* {
    final fetcherUri = Uri.parse(fetcherUrl);
    final queryParameters = {'url': param.uri.toString()};

    if (param.fit != null) {
      queryParameters.putIfAbsent('fit', () => param.fit.toString());
    }

    if (param.width != null) {
      queryParameters.putIfAbsent('w', () => param.width.toString());
    }

    if (param.height != null) {
      queryParameters.putIfAbsent('h', () => param.height.toString());
    }

    if (param.blur != null) {
      queryParameters.putIfAbsent('blur', () => param.blur.toString());
    }

    if (param.rotation != null) {
      queryParameters.putIfAbsent('rot', () => param.rotation.toString());
    }

    if (param.tint != null) {
      queryParameters.putIfAbsent('tint', () => param.tint.toString());
    }

    yield fetcherUri.replace(path: '/', queryParameters: queryParameters);
  }
}

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

  /// Creates new parameters for fetching an image via a proxy.
  const FetcherParams({
    required this.uri,
    this.width,
    this.height,
    this.fit,
    this.blur,
    this.rotation,
    this.tint,
  });
}
