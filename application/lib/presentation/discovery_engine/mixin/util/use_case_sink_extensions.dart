import 'package:xayn_architecture/concepts/use_case/handlers/on_failure.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_stream.dart';

/// A helper to auto-subscribe to the piped use case handlers inside
/// Discovery engine mixins.
extension UseCaseValueStreamExtension<Out> on UseCaseValueStream<Out> {
  void autoSubscribe({
    required HandleOnFailure onError,
    HandleValue<Out>? onValue,
  }) =>
      fold(
        defaultOnError: onError,
        onValue: onValue ?? (_) {},
      );
}

/// A helper to auto-subscribe to the piped use case handlers inside
/// Discovery engine mixins.
extension UseCaseSinkExtension<In, Out> on UseCaseSink<In, Out> {
  void autoSubscribe({
    required HandleOnFailure onError,
    HandleValue<Out>? onValue,
  }) =>
      fold(
        defaultOnError: onError,
        onValue: onValue ?? (_) {},
      );
}
