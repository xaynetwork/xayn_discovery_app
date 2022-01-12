import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_state.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';

@injectable
class CollectionsScreenManager extends Cubit<CollectionsScreenState>
    with UseCaseBlocHelper<CollectionsScreenState> {
  final CreateCollectionUseCase _createCollectionUseCase;
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final RenameCollectionUseCase _renameCollectionUseCase;
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final CollectionErrorsEnumMapper _collectionErrorsEnumMapper;
  final DateTimeHandler _dateTimeHandler;

  CollectionsScreenManager._(
    this._createCollectionUseCase,
    this._removeCollectionUseCase,
    this._renameCollectionUseCase,
    this._listenCollectionsUseCase,
    this._collectionErrorsEnumMapper,
    this._dateTimeHandler,
    this._collections,
  ) : super(CollectionsScreenState.initial()) {
    _init();
  }

  @factoryMethod
  static Future<CollectionsScreenManager> create(
    CreateCollectionUseCase createCollectionUseCase,
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    RemoveCollectionUseCase removeCollectionUseCase,
    RenameCollectionUseCase renameCollectionUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    CollectionErrorsEnumMapper collectionErrorsEnumMapper,
    DateTimeHandler dateTimeHandler,
  ) async {
    final collections =
        (await getAllCollectionsUseCase.singleOutput(none)).collections;

    return CollectionsScreenManager._(
      createCollectionUseCase,
      removeCollectionUseCase,
      renameCollectionUseCase,
      listenCollectionsUseCase,
      collectionErrorsEnumMapper,
      dateTimeHandler,
      collections,
    );
  }

  late List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  String? _useCaseError;

  void _init() {
    _collectionsHandler = consume(_listenCollectionsUseCase, initialData: none);
  }

  void createCollection({required String collectionName}) async {
    _useCaseError = null;
    final useCaseOut =
        await _createCollectionUseCase.singleOutput(collectionName);

    /// We just need to handle the failure case.
    /// In case of success we will automatically get the updated list of Collections
    /// since we are listening to the repo through the [ListenCollectionsUseCase]
    useCaseOut.mapOrNull(
      failure: (useCaseOut) => scheduleComputeState(
        () => _useCaseError = _collectionErrorsEnumMapper.mapEnumToString(
          useCaseOut.error,
        ),
      ),
    );
  }

  void renameCollection({
    required UniqueId collectionId,
    required String newName,
  }) async {
    _useCaseError = null;
    final param = RenameCollectionUseCaseParam(
      collectionId: collectionId,
      newName: newName,
    );
    final useCaseOut = await _renameCollectionUseCase.singleOutput(param);

    /// We just need to handle the failure case.
    /// In case of success we will automatically get the updated list of Collections
    /// since we are listening to the repo through the [ListenCollectionsUseCase]
    useCaseOut.mapOrNull(
      failure: (useCaseOut) => scheduleComputeState(
        () => _useCaseError = _collectionErrorsEnumMapper.mapEnumToString(
          useCaseOut.error,
        ),
      ),
    );
  }

  void removeCollection({
    required UniqueId collectionIdToRemove,
    UniqueId? collectionIdMoveBookmarksTo,
  }) async {
    _useCaseError = null;
    final param = RemoveCollectionUseCaseParam(
      collectionIdToRemove: collectionIdToRemove,
      collectionIdMoveBookmarksTo: collectionIdMoveBookmarksTo,
    );
    final useCaseOut = await _removeCollectionUseCase.singleOutput(param);

    /// We just need to handle the failure case.
    /// In case of success we will automatically get the updated list of Collections
    /// since we are listening to the repo through the [ListenCollectionsUseCase]
    useCaseOut.mapOrNull(
      failure: (useCaseOut) => scheduleComputeState(
        () => _useCaseError = _collectionErrorsEnumMapper.mapEnumToString(
          useCaseOut.error,
        ),
      ),
    );
  }

  @override
  Future<CollectionsScreenState?> computeState() async {
    String errorMsg;
    if (_useCaseError != null) {
      return state.copyWith(errorMsg: _useCaseError);
    }

    return fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
      if (errorReport.exists(_collectionsHandler)) {
        final error = errorReport.of(_collectionsHandler)!.error;

        errorMsg = error.toString();

        return state.copyWith(
          errorMsg: errorMsg,
        );
      }
      final newTimestamp = _dateTimeHandler.getDateTimeNow();
      if (usecaseOut != null) {
        _collections = usecaseOut.collections;
      }
      return CollectionsScreenState.populated(
        _collections,
        newTimestamp,
      );
    });
  }
}
