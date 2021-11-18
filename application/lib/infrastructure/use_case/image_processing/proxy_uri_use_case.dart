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
  ProxyUriUseCase({this.fetcherUrl = Env.imageFetcherUrl});

  @override
  Stream<Uri> transaction(FetcherParams param) async* {
    final fetcherUri = Uri.parse(fetcherUrl);
    final queryParameters = {
      'url': param.uri.toString(),
      'fit': 'cover',
    };
    final hasWidth = param.uri.queryParameters.containsKey('w');
    final hasHeight = param.uri.queryParameters.containsKey('h');
    final hasEitherSize = hasWidth || hasHeight;

    if (!hasEitherSize) {
      if (param.width != null) {
        queryParameters.putIfAbsent('w', () => param.width.toString());
      }

      if (param.height != null) {
        queryParameters.putIfAbsent('h', () => param.height.toString());
      }
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

  /// Creates new parameters for fetching an image via a proxy.
  const FetcherParams({
    required this.uri,
    this.width,
    this.height,
  });
}
