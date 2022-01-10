import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';

/// Adds a timestamp to a [DiscoveryCardObservation].
@injectable
class DiscoveryCardObservationUseCase extends UseCase<DiscoveryCardObservation,
    TimestampedDiscoveryCardObservation> {
  @override
  Stream<TimestampedDiscoveryCardObservation> transaction(
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

    if (param.first.value.document != null) {
      yield DiscoveryCardMeasuredObservation.fromObservable(
        observable: param.first.value,
        duration: duration,
      );
    }
  }
}
