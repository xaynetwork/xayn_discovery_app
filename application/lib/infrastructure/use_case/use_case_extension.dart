import 'package:xayn_architecture/xayn_architecture.dart';

/// This is a temporary extension.
/// This code should be ported to the `xayn_architecture` package
extension UseCaseResultExtension<T> on List<UseCaseResult<T>> {
  T get singleValue {
    late final T value;
    single.fold(
      defaultOnError: (_, __) {
        throw Exception();
      },
      onValue: (_) => value = _,
    );
    return value;
  }
}

class None {
  const None._();
}

const none = None._();
