import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/infrastructure/util/async_init.dart';

class TestInitializer with AsyncInitMixin {
  bool isInitialized = false;

  @override
  Future<void> init() async {
    await Future.delayed(Duration.zero);
    isInitialized = await Future.value(true);
  }
}

void main() {
  test(
      'Initializing AsyncInits will register their operation in a static registry [in test]',
      () async {
    final initializer1 = TestInitializer();
    final initializer2 = TestInitializer();
    initializer1.startInitializing();
    initializer2.startInitializing();

    await AsyncInitMixin.cancelAll();

    expect(initializer1.isCancelled, true);
    expect(initializer2.isCancelled, true);
    expect(initializer1.isInitialized, false);
    expect(initializer2.isInitialized, false);
  });

  test('AsyncInits will not run an operation before initialized.', () async {
    final initializer = TestInitializer();
    initializer.startInitializing();

    var run = false;
    // ignore: invalid_use_of_protected_member
    initializer.safeRun(() {
      run = true;
    });

    expect(run, false);
    expect(initializer.isInitialized, false);
  });

  test('AsyncInits will  run an operation after initialized.', () async {
    final initializer = TestInitializer();
    initializer.startInitializing();

    var run = false;
    // ignore: invalid_use_of_protected_member
    initializer.safeRun(() {
      run = true;
    });

    await Future.delayed(const Duration(milliseconds: 1));

    expect(run, true);
    expect(initializer.isInitialized, true);
  });

  test('AsyncInits will not run an operation when the init was cancelled.',
      () async {
    final initializer = TestInitializer();
    initializer.startInitializing();

    var run = false;
    // ignore: invalid_use_of_protected_member
    initializer.safeRun(() {
      run = true;
    });

    await initializer.cancelInit();
    await Future.delayed(const Duration(milliseconds: 1));

    expect(run, false);
    expect(initializer.isCancelled, true);
  });
}
