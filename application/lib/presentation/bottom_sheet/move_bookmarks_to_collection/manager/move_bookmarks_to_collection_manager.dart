import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/collection_deleted_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

import 'move_bookmarks_to_collection_state.dart';

@injectable
class MoveBookmarksToCollectionManager
    extends Cubit<MoveBookmarksToCollectionState>
    with UseCaseBlocHelper<MoveBookmarksToCollectionState> {
  final ListenCollectionsUseCase _listenCollectionsUseCase;
  final MoveBookmarksUseCase _moveBookmarksUseCase;
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final GetAllCollectionsUseCase _getAllCollectionsUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

  final List<Collection> _collections = [];
  late final UseCaseValueStream<ListenCollectionsUseCaseOut>
      _collectionsHandler =
      consume(_listenCollectionsUseCase, initialData: none);
  UniqueId? _selectedCollectionId;

  MoveBookmarksToCollectionManager(
    this._listenCollectionsUseCase,
    this._moveBookmarksUseCase,
    this._removeCollectionUseCase,
    this._getAllCollectionsUseCase,
    this._sendAnalyticsUseCase,
  ) : super(MoveBookmarksToCollectionState.initial());

  void enteringScreen({
    required UniqueId collectionIdToRemove,
    UniqueId? selectedCollectionId,
  }) async {
    final useCaseResult = await _getAllCollectionsUseCase.singleOutput(none);
    _collections
      ..clear()
      ..addAll(useCaseResult.collections);

    _collections.removeWhere((element) => element.id == collectionIdToRemove);
    scheduleComputeState(
      () =>
          _selectedCollectionId = selectedCollectionId ?? _collections.first.id,
    );
  }

  void updateSelectedCollection(UniqueId? collectionId) {
    if (collectionId == null) return;
    scheduleComputeState(() => _selectedCollectionId = collectionId);
  }

  Future<void> onApplyPressed({
    required List<UniqueId> bookmarksIds,
    required UniqueId collectionIdToRemove,
  }) async {
    await _moveBookmarksUseCase.call(
      MoveBookmarksUseCaseIn(
        bookmarkIds: bookmarksIds,
        collectionId: state.selectedCollectionId!,
      ),
    );
    _removeCollectionUseCase.call(
      RemoveCollectionUseCaseParam(
        collectionIdToRemove: collectionIdToRemove,
      ),
    );
    _sendAnalyticsUseCase(
      CollectionDeletedEvent(context: DeleteCollectionContext.moveBookmarks),
    );
  }

  @override
  Future<MoveBookmarksToCollectionState?> computeState() async =>
      fold(_collectionsHandler).foldAll((usecaseOut, errorReport) {
        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_collectionsHandler)!.error;
          logger.e(error);
          return state.copyWith(error: ErrorObject(error));
        }

        if (usecaseOut != null) {
          _collections
            ..clear()
            ..addAll(usecaseOut.collections);
        }

        final newState = MoveBookmarksToCollectionState.populated(
          collections: _collections,
          selectedCollectionId: _selectedCollectionId,
        );

        return newState;
      });
}
