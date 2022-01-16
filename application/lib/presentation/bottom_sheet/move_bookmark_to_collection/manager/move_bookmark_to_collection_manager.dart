import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_state.dart';

@injectable
class MoveBookmarkToCollectionManager
    extends Cubit<MoveBookmarkToCollectionState>
    with UseCaseBlocHelper<MoveBookmarkToCollectionState> {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final MoveBookmarkUseCase _moveBookmarkUseCase;

  late List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  Collection? _selectedCollection;

  MoveBookmarkToCollectionManager._(
    this._listenCollectionsUseCase,
    this._moveBookmarkUseCase,
    this._collections,
  ) : super(MoveBookmarkToCollectionState.initial()) {
    _init();
  }

  @factoryMethod
  static Future<MoveBookmarkToCollectionManager> create(
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    MoveBookmarkUseCase moveBookmarkUseCase,
  ) async {
    // final collections =
    //     (await getAllCollectionsUseCase.singleOutput(none)).collections;
    final collections = [
      Collection.readLater(name: 'read later'),
      Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
      // Collection(id: UniqueId(), index: 1, name: 'lol'),
    ];
    return MoveBookmarkToCollectionManager._(
      listenCollectionsUseCase,
      moveBookmarkUseCase,
      collections,
    );
  }

  void _init() async {
    _selectedCollection = _collections.first;
    _collectionsHandler = consume(_listenCollectionsUseCase, initialData: none);
  }

  void updateSelectedCollection(Collection collection) =>
      scheduleComputeState(() => _selectedCollection = collection);

  Future<void> moveBookmarkToSelectedCollection(
      {required UniqueId bookmarkId}) async {
    final param = MoveBookmarkUseCaseIn(
        bookmarkId: bookmarkId, collectionId: state.selectedCollection!.id);
    await _moveBookmarkUseCase.call(param);
  }

  @override
  Future<MoveBookmarkToCollectionState?> computeState() async {
    return fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
      if (errorReport.exists(_collectionsHandler)) {
        final error = errorReport.of(_collectionsHandler)!.error;
        return state.copyWith(errorMsg: error.toString());
      }

      if (usecaseOut != null) {
        _collections = usecaseOut.collections;
      }

      final newState = state.copyWith(
        collections: _collections,
        selectedCollection: _selectedCollection,
      );

      return newState;
    });
  }
}
