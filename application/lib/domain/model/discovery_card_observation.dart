import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';

class DiscoveryCardObservation {
  final Document? document;
  final DocumentViewMode? viewType;

  const DiscoveryCardObservation({
    required this.document,
    required this.viewType,
  });

  const DiscoveryCardObservation.none()
      : document = null,
        viewType = null;
}

class DiscoveryCardMeasuredObservation extends DiscoveryCardObservation {
  final Duration duration;

  DiscoveryCardMeasuredObservation.fromObservable({
    required DiscoveryCardObservation observable,
    required this.duration,
  }) : super(
          document: observable.document,
          viewType: observable.viewType,
        );
}

typedef TimestampedDiscoveryCardObservation
    = Timestamped<DiscoveryCardObservation>;

typedef DiscoveryCardObservationPair
    = Iterable<TimestampedDiscoveryCardObservation>;
