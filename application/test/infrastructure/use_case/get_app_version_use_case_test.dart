import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/use_case_extension.dart';

import 'get_app_version_use_case_test.mocks.dart';

@GenerateMocks([PackageInfo])
void main() {
  late MockPackageInfo info;
  late GetAppVersionUseCase useCase;
  setUp(() {
    info = MockPackageInfo();
    useCase = GetAppVersionUseCase(info);

    when(info.version).thenReturn('1.2.3');
    when(info.buildNumber).thenReturn('321');
  });
  test(
    'WHEN call useCase as Future THEN verify correct order',
    () async {
      await useCase.call(null);

      verifyInOrder([
        info.version,
        info.buildNumber,
      ]);
      verifyNoMoreInteractions(info);
    },
  );
  test(
    'WHEN call useCase as Future twice THEN verify return previously calculated value',
    () async {
      final result0 = (await useCase.call(null)).singleValue;
      final result1 = (await useCase.call(null)).singleValue;

      expect(result0, equals(result1));

      verify(info.version);
      verify(info.buildNumber);
      verifyNoMoreInteractions(info);
    },
  );
}
