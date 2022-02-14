import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/manager/delete_collection_confirmation_state.dart';

import '../../../utils/logger/logger.dart';

@injectable
class DeleteCollectionConfirmationManager
    extends Cubit<DeleteCollectionConfirmationState>
    with UseCaseBlocHelper<DeleteCollectionConfirmationState> {
  final RemoveCollectionUseCase _removeCollectionUseCase;
  final RemoveBookmarskUseCase _removeBookmarskUseCase;
  final GetAllBookmarksUseCase _getAllBookmarksUseCase;

  late UniqueId _collectionId;
  late final UseCaseSink<GetAllBookmarksUseCaseIn, GetAllBookmarksUseCaseOut>
      _getBookmarksHandler = pipe(_getAllBookmarksUseCase);

  final List<UniqueId> _bookmarksIds = [];

  DeleteCollectionConfirmationManager(
    this._removeCollectionUseCase,
    this._getAllBookmarksUseCase,
    this._removeBookmarskUseCase,
  ) : super(DeleteCollectionConfirmationState.initial());

  void enteringScreen(UniqueId collectionId) {
    _collectionId = collectionId;
    _getBookmarksHandler(
      GetAllBookmarksUseCaseIn(
        collectionId: _collectionId,
      ),
    );
  }

  Future<void> deleteAll() async {
    await _removeBookmarskUseCase.call(RemoveBookmarskUseCaseIn(
      bookmarksIds: state.bookmarksIds,
    ));
    await deleteCollection();
  }

  Future<void> deleteCollection() async {
    await _removeCollectionUseCase.call(
      RemoveCollectionUseCaseParam(
        collectionIdToRemove: _collectionId,
      ),
    );
  }

  @override
  Future<DeleteCollectionConfirmationState?> computeState() async =>
      fold(_getBookmarksHandler).foldAll((usecaseOut, errorReport) {
        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_getBookmarksHandler)!.error;
          logger.e(error);
          return state.copyWith(errorMsg: error.toString());
        }

        if (usecaseOut != null) {
          _bookmarksIds
            ..clear()
            ..addAll(
              usecaseOut.bookmarks.map((e) => e.id).toList(),
            );
        }

        final newState = DeleteCollectionConfirmationState.populated(
          bookmarksIds: _bookmarksIds,
        );

        return newState;
      });
}
