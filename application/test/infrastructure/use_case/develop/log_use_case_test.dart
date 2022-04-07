import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockLogger logger;

  setUp(() {
    logger = MockLogger();
  });

  group('LogUseCase: ', () {
    useCaseTest(
      'WHEN level is null THEN log with the default Level.info ',
      build: () => LogUseCase(
        (String param) => 'logged $param',
        logger: logger,
      ),
      input: const ['hi!'],
      verify: (_) => verify(logger.log(Level.info, 'logged hi!')).called(1),
      expect: [useCaseSuccess('hi!')],
    );
    useCaseTest(
      'WHEN level is not null THEN log with the level passed',
      build: () => LogUseCase(
        (String param) => 'logged $param',
        logger: logger,
        level: Level.debug,
      ),
      input: const ['hi!'],
      verify: (_) => verify(logger.log(Level.debug, 'logged hi!')).called(1),
      expect: [useCaseSuccess('hi!')],
    );

    useCaseTest(
      'Can log conditionally: ',
      build: () => LogUseCase(
        (int param) => 'logged $param',
        when: (int param) => param >= 2,
        logger: logger,
      ),
      input: const [0, 1, 2, 3],
      verify: (_) => verify(logger.log(Level.info, any)).called(2),
      expect: [
        useCaseSuccess(0),
        useCaseSuccess(1),
        useCaseSuccess(2),
        useCaseSuccess(3),
      ],
    );
  });
}
