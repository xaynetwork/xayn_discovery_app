import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';

import 'log_use_case_test.mocks.dart';

@GenerateMocks([Log])
void main() {
  late MockLog logger;

  setUp(() {
    logger = MockLog();
  });

  group('LogUseCase: ', () {
    useCaseTest(
      'Can log incoming events: ',
      build: () => LogUseCase(
        (String param) => 'logged $param',
        log: logger.log,
      ),
      input: const ['hi!'],
      verify: (_) => verify(logger.log('logged hi!')).called(1),
      expect: [useCaseSuccess('hi!')],
    );

    useCaseTest(
      'Can log conditionally: ',
      build: () => LogUseCase(
        (int param) => 'logged $param',
        when: (int param) => param >= 2,
        log: logger.log,
      ),
      input: const [0, 1, 2, 3],
      verify: (_) => verify(logger.log(any)).called(2),
      expect: [
        useCaseSuccess(0),
        useCaseSuccess(1),
        useCaseSuccess(2),
        useCaseSuccess(3),
      ],
    );
  });
}

class Log {
  void log(
    String message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
