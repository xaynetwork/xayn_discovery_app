import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/caching/cache_manager_use_case.dart';

void main() {
  setUp(() {});

  group('CacheManagerUseCase: ', () {
    useCaseTest(
      'Can log incoming events: ',
      build: () => CacheManagerUseCase.withAppImageCacheManager(),
      input: [
        Uri.parse(
            'https://www.ukri.org/wp-content/uploads/2021/09/UKRI-200921-Llama-antibody-COVID-19-Getty.jpg')
      ],
      expect: [useCaseSuccess('hi!')],
    );
  });
}
