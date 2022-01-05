import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_exception.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_state.dart';

@injectable
class CollectionsScreenManager extends Cubit<CollectionsScreenState>
    with UseCaseBlocHelper<CollectionsScreenState> {
  final CreateCollectionUseCase _createCollectionUseCase;
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final RenameCollectionUseCase _renameCollectionUseCase;
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final DateTimeHandler _dateTimeHandler;

  @visibleForTesting
  CollectionsScreenManager(
    this._createCollectionUseCase,
    this._removeCollectionUseCase,
    this._renameCollectionUseCase,
    this._listenCollectionsUseCase,
    this._dateTimeHandler,
    this._collections,
  ) : super(CollectionsScreenState.initial()) {
    init();
  }

  @factoryMethod
  static Future<CollectionsScreenManager> create(
    CreateCollectionUseCase createCollectionUseCase,
    GetAllCollectionsUseCase getAllCollectionsUseCase,
    RemoveCollectionUseCase removeCollectionUseCase,
    RenameCollectionUseCase renameCollectionUseCase,
    ListenCollectionsUseCase listenCollectionsUseCase,
    DateTimeHandler dateTimeHandler,
  ) async {
    final collections =
        (await getAllCollectionsUseCase.singleOutput(none)).collections;

    return CollectionsScreenManager(
      createCollectionUseCase,
      removeCollectionUseCase,
      renameCollectionUseCase,
      listenCollectionsUseCase,
      dateTimeHandler,
      collections,
    );
  }

  late List<Collection> _collections;
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler;
  dynamic _useCaseError;

  void init() {
    _collectionsHandler = consume(_listenCollectionsUseCase, initialData: none);
  }

  void createCollection({required String collectionName}) {
    _useCaseError = null;
    _createCollectionUseCase.singleOutput(collectionName).catchError(
      (e, _) {
        scheduleComputeState(() => _useCaseError = e);

        /// We need to return a FutureOr<Collection?>
        /// The tests don't work without the return statement
        return null;
      },
    );
  }

  void renameCollection({
    required UniqueId collectionId,
    required String newName,
  }) {
    _useCaseError = null;
    final param = RenameCollectionUseCaseParam(
      collectionId: collectionId,
      newName: newName,
    );
    _renameCollectionUseCase.singleOutput(param).catchError(
      (e, _) {
        scheduleComputeState(() => _useCaseError = e);

        /// We need to return a FutureOr<Collection?>
        /// The tests don't work without the return statement
        return null;
      },
    );
  }

  void removeCollection({
    required UniqueId collectionIdToRemove,
    UniqueId? collectionIdMoveBookmarksTo,
  }) {
    _useCaseError = null;
    final param = RemoveCollectionUseCaseParam(
      collectionIdToRemove: collectionIdToRemove,
      collectionIdMoveBookmarksTo: collectionIdMoveBookmarksTo,
    );
    _removeCollectionUseCase.singleOutput(param).catchError(
      (e, _) {
        scheduleComputeState(() => _useCaseError = e);

        /// We need to return a FutureOr<Collection?>
        /// The tests don't work without the return statement
        return null;
      },
    );
  }

  @override
  Future<CollectionsScreenState?> computeState() async {
    String errorMsg;
    if (_useCaseError != null) {
      final error = _useCaseError;
      if (error is CollectionUseCaseException) {
        errorMsg = error.msg;
      } else {
        errorMsg = error.toString();
      }
      return state.copyWith(errorMsg: errorMsg);
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
