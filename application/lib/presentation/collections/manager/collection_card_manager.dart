import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_exception.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_collection_card_data_use_case.dart';

import 'collection_card_state.dart';

class CollectionCardManager extends Cubit<CollectionCardState>
    with UseCaseBlocHelper<CollectionCardState> {
  final GetCollectionCardDataUseCase _getCollectionCardDataUseCase;

  CollectionCardManager(
    this._getCollectionCardDataUseCase,
  ) : super(
          CollectionCardState.initial(),
        );

  int numOfItems = 0;
  Uint8List? image;
  dynamic _useCaseError;

  Future<void> retrieveCollectionCardInfo(UniqueId collectionId) async {
    _useCaseError = null;
    final result = await _getCollectionCardDataUseCase
        .singleOutput(collectionId)
        .catchError((e, _) {
      scheduleComputeState(() => _useCaseError = e);
      return null;
    });

    scheduleComputeState(() {
      if (result != null) {
        numOfItems = result.numOfItems;
        image = result.image;
      }
    });
  }

  @override
  Future<CollectionCardState?> computeState() async {
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
    return CollectionCardState.populated(
      numOfItems: numOfItems,
      image: image,
    );
  }
}
