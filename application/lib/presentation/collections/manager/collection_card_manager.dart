import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_collection_card_data_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';

import 'collection_card_state.dart';

class CollectionCardManager extends Cubit<CollectionCardState>
    with UseCaseBlocHelper<CollectionCardState> {
  final GetCollectionCardDataUseCase _getCollectionCardDataUseCase;
  final CollectionErrorsEnumMapper _collectionErrorsEnumMapper;

  CollectionCardManager(
    this._getCollectionCardDataUseCase,
    this._collectionErrorsEnumMapper,
  ) : super(
          CollectionCardState.initial(),
        );

  int numOfItems = 0;
  Uint8List? image;
  String? _useCaseError;

  Future<void> retrieveCollectionCardInfo(UniqueId collectionId) async {
    _useCaseError = null;
    final useCaseOut = await _getCollectionCardDataUseCase.call(collectionId);
    useCaseOut.last.fold(
      defaultOnError: _defaultOnError,
      matchOnError: {
        On<CollectionUseCaseError>(_matchOnCollectionUseCaseError)
      },
      onValue: _onValue,
    );
  }

  @override
  Future<CollectionCardState?> computeState() async {
    if (_useCaseError != null) {
      return state.copyWith(errorMsg: _useCaseError);
    }
    return CollectionCardState.populated(
      numOfItems: numOfItems,
      image: image,
    );
  }

  void _defaultOnError(Object e, StackTrace? s) =>
      scheduleComputeState(() => _useCaseError = e.toString());

  void _matchOnCollectionUseCaseError(Object e, StackTrace? s) =>
      scheduleComputeState(
        () => _useCaseError = _collectionErrorsEnumMapper.mapEnumToString(
          e as CollectionUseCaseError,
        ),
      );

  void _onValue(GetCollectionCardDataUseCaseOut out) => scheduleComputeState(
        () {
          numOfItems = out.numOfItems;
          image = out.image;
        },
      );
}
