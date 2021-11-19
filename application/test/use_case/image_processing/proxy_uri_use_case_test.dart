import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/proxy_uri_use_case.dart';

void main() {
  const testFetcherUrl = 'https://fetch.me';
  final testImageUri = Uri.parse('https://www.xayn.com');

  setUp(() {});

  group('ProxyUriUseCase: ', () {
    useCaseTest(
      'Creates a valid proxy Uri: ',
      build: () => ProxyUriUseCase(
        fetcherUrl: testFetcherUrl,
      ),
      input: [FetcherParams(uri: testImageUri)],
      expect: [
        useCaseSuccess(
          Uri.parse(testFetcherUrl).replace(
            path: '/',
            queryParameters: {
              'url': testImageUri.toString(),
            },
          ),
        )
      ],
    );

    useCaseTest(
      'Can include width and height: ',
      build: () => ProxyUriUseCase(fetcherUrl: testFetcherUrl),
      input: [
        FetcherParams(
          uri: testImageUri,
          width: 10,
          height: 10,
          fit: 'cover',
          blur: 3,
          tint: 'blue',
          rotation: 45,
        )
      ],
      expect: [
        useCaseSuccess(
          Uri.parse(testFetcherUrl).replace(
            path: '/',
            queryParameters: {
              'url': testImageUri.toString(),
              'fit': 'cover',
              'w': '10',
              'h': '10',
              'blur': '3',
              'rot': '45',
              'tint': 'blue',
            },
          ),
        )
      ],
    );
  });
}
