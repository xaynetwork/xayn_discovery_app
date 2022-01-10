import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document_view_type.dart';

class DiscoveryCardObservation {
  final Document? document;
  final DocumentViewType? viewType;

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
