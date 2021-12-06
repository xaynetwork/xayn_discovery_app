import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';

typedef DiscoveryCardObservationPair
    = Iterable<Timestamped<DiscoveryCardObservation>>;

/// Adds a timestamp to a [DiscoveryCardObservation].
@injectable
class DiscoveryCardObservationUseCase extends UseCase<DiscoveryCardObservation,
    Timestamped<DiscoveryCardObservation>> {
  @override
  Stream<Timestamped<DiscoveryCardObservation>> transaction(
      DiscoveryCardObservation param) {

    return Stream.value(param).timestamp();
  }
}

@injectable
class DiscoveryCardMeasuredObservationUseCase extends UseCase<
    DiscoveryCardObservationPair, DiscoveryCardMeasuredObservation> {
  @override
  Stream<DiscoveryCardMeasuredObservation> transaction(
      DiscoveryCardObservationPair param) async* {
    final duration = param.last.timestamp.difference(param.first.timestamp);

    yield DiscoveryCardMeasuredObservation.fromObservable(
      observable: param.first.value,
      duration: duration,
    );
  }
}

class DiscoveryCardObservation {
  final Document document;
  final DocumentViewType viewType;

  const DiscoveryCardObservation({
    required this.document,
    required this.viewType,
  });
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
