import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/subscription_window_observation.dart';

typedef SubscriptionWindowObservationPair
    = Iterable<Timestamped<SubscriptionWindowObservation>>;

/// Adds a timestamp to a [SubscriptionWindowObservation].
@injectable
class SubscriptionWindowObservationUseCase extends UseCase<
    SubscriptionWindowObservation, TimestampedSubscriptionWindowObservation> {
  @override
  Stream<TimestampedSubscriptionWindowObservation> transaction(
      SubscriptionWindowObservation param) {
    return Stream.value(param).timestamp();
  }
}

@injectable
class SubscriptionWindowMeasuredObservationUseCase extends UseCase<
    SubscriptionWindowObservationPair, SubscriptionWindowMeasuredObservation> {
  @override
  Stream<SubscriptionWindowMeasuredObservation> transaction(
      SubscriptionWindowObservationPair param) async* {
    final duration = param.last.timestamp.difference(param.first.timestamp);

    if (param.first.value.currentView != null &&
        param.first.value.type == SubscriptionWindowObservationType.open &&
        param.last.value.type == SubscriptionWindowObservationType.close) {
      yield SubscriptionWindowMeasuredObservation.fromObservable(
        observable: param.first.value,
        duration: duration,
      );
    }
  }
}
