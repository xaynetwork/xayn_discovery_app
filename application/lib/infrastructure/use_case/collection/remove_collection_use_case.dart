import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

@injectable
class RemoveCollectionUseCase extends UseCase<Collection, None> {
  final CollectionsRepository _collectionsRepository;
  final BookmarksRepository _bookmarksRepository;

  RemoveCollectionUseCase(
    this._collectionsRepository,
    this._bookmarksRepository,
  );

  @override
  Stream<None> transaction(Collection param) async* {
    _bookmarksRepository.removeAllByCollectionId(param.id);
    _collectionsRepository.remove(param);
    yield none;
  }
}
