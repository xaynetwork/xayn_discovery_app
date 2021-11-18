import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

/// A [UseCase] which loads the color palette from the image which exists
/// at the Uri that is provided as input.
@injectable
class ProxyUriUseCase extends UseCase<FetcherParams, Uri> {
  final String fetcherUrl;

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

class FetcherParams {
  final Uri uri;
  final int? width;
  final int? height;

  const FetcherParams({
    required this.uri,
    this.width,
    this.height,
  });
}
