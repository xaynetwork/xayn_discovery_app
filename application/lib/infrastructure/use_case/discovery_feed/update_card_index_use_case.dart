import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';

@injectable
class UpdateCardIndexUseCase extends UseCase<int, int> {
  final FeedRepository feedRepository;

  UpdateCardIndexUseCase(this.feedRepository);

  @override
  Stream<int> transaction(int param) async* {
    final feed = feedRepository.get().copyWith(cardIndex: param);

    feedRepository.save(feed);

    yield param;
  }
}
