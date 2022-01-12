import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';

import 'collection_use_cases_outputs.dart';

/// UseCase that retrieves data to show in the collection card:
/// 1) number of items
/// 2) background image
///
/// Input:
/// [UniqueId]: id of the collection we want to retrieve card data for.
///
/// Output:
/// [GetCollectionCardDataUseCaseOut?]: contains the values retrieved.
/// If an error occurs, an exception is thrown.
/// It's nullable because in case we want to catch the error with the Future.catchError callback
/// we can then return null, since when an error occurs no data has been retrieved.
@injectable
class GetCollectionCardDataUseCase
    extends UseCase<UniqueId, GetCollectionCardDataUseCaseOut> {
  final BookmarksRepository _bookmarksRepository;
  final CollectionsRepository _collectionsRepository;

  GetCollectionCardDataUseCase(
    this._bookmarksRepository,
    this._collectionsRepository,
  );

  @override
  Stream<GetCollectionCardDataUseCaseOut> transaction(UniqueId param) async* {
    final collection = _collectionsRepository.getById(param);

    if (collection == null) {
      yield const GetCollectionCardDataUseCaseOut.failure(
          CollectionUseCaseErrorEnum
              .tryingToGetCardDataForNotExistingCollection);
      return;
    }
    final bookmarks = _bookmarksRepository.getByCollectionId(param);
    yield GetCollectionCardDataUseCaseOut.success(
      numOfItems: bookmarks.length,
      image: bookmarks.last.image,
    );
  }
}
