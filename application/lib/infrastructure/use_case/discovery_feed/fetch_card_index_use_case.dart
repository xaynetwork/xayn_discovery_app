import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';

@injectable
class FetchCardIndexUseCase extends UseCase<None, int> {
  final FeedRepository feedRepository;

  FetchCardIndexUseCase(this.feedRepository);

  @override
  Stream<int> transaction(None param) async* {
    final feed = feedRepository.get();

    yield feed.cardIndex;
  }
}
