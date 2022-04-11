import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collection_card_data_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import 'collection_card_state.dart';

@injectable
class CollectionCardManager extends Cubit<CollectionCardState>
    with UseCaseBlocHelper<CollectionCardState> {
  final ListenCollectionCardDataUseCase _listenCollectionCardDataUseCase;
  final CollectionErrorsEnumMapper _collectionErrorsEnumMapper;

  CollectionCardManager(
    this._listenCollectionCardDataUseCase,
    this._collectionErrorsEnumMapper,
  ) : super(
          CollectionCardState.initial(),
        );

  late final UseCaseSink<UniqueId, GetCollectionCardDataUseCaseOut>
      _listenBookmarksHandler = pipe(_listenCollectionCardDataUseCase);

  Future<void> retrieveCollectionCardInfo(UniqueId collectionId) async {
    _listenBookmarksHandler.call(collectionId);
  }

  @override
  Future<CollectionCardState?> computeState() async =>
      fold(_listenBookmarksHandler).foldAll((bookmarkEvent, errorReport) {
        final error = errorReport.of(_listenBookmarksHandler);
        if (error != null) {
          final errorMessage = error.error is CollectionUseCaseError
              ? _collectionErrorsEnumMapper.mapEnumToString(
                  error.error as CollectionUseCaseError,
                )
              : error.error.toString();

          logger.e('Error when fetching collection card data.', error.error,
              error.stackTrace);
          return state.copyWith(errorMsg: errorMessage);
        }

        if (bookmarkEvent != null) {
          return CollectionCardState.populated(
            numOfItems: bookmarkEvent.numOfItems,
            image: bookmarkEvent.image,
          );
        }

        return state;
      });
}
