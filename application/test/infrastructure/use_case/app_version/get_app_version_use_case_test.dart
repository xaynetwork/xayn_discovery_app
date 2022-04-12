import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';

import '../../../test_utils/utils.dart';

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
      await useCase.call(none);

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
      final result0 = (await useCase.singleOutput(none));
      final result1 = (await useCase.singleOutput(none));

      expect(result0, equals(result1));

      verify(info.version);
      verify(info.buildNumber);
      verifyNoMoreInteractions(info);
    },
  );
}
