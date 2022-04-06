import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_subscription_window_event.dart';

enum SubscriptionWindowObservationType {
  open,
  close,
}

class SubscriptionWindowObservation {
  final SubscriptionWindowCurrentView? currentView;
  final SubscriptionWindowObservationType? type;

  const SubscriptionWindowObservation({
    required this.currentView,
    required this.type,
  });
}

class SubscriptionWindowMeasuredObservation
    extends SubscriptionWindowObservation {
  final Duration duration;

  SubscriptionWindowMeasuredObservation.fromObservable({
    required SubscriptionWindowObservation observable,
    required this.duration,
  }) : super(
          currentView: observable.currentView,
          type: observable.type,
        );
}

typedef TimestampedSubscriptionWindowObservation
    = Timestamped<SubscriptionWindowObservation>;

typedef SubscriptionWindowObservationPair
    = Iterable<TimestampedSubscriptionWindowObservation>;
