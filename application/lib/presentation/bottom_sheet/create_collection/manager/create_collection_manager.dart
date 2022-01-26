import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';

import 'create_collection_state.dart';

@injectable
class CreateCollectionManager extends Cubit<CreateCollectionState>
    with UseCaseBlocHelper<CreateCollectionState> {
  final CreateCollectionUseCase _createCollectionUseCase;
  final CollectionErrorsEnumMapper _collectionErrorsEnumMapper;

  String? _useCaseError;
  String _collectionName = '';

  CreateCollectionManager(
    this._createCollectionUseCase,
    this._collectionErrorsEnumMapper,
  ) : super(const CreateCollectionState());

  void updateCollectionName(String name) => scheduleComputeState(
        () {
          _collectionName = name;
          _useCaseError = null;
        },
      );

  void _defaultOnError(Object e, StackTrace? s) =>
      scheduleComputeState(() => _useCaseError = e.toString());

  void _matchOnCollectionUseCaseError(Object e, StackTrace? s) =>
      scheduleComputeState(
        () => _useCaseError = _collectionErrorsEnumMapper.mapEnumToString(
          e as CollectionUseCaseError,
        ),
      );

  Future<Collection?> createCollection() async {
    final useCaseOut =
        await _createCollectionUseCase.call(state.collectionName);

    Collection? _collection;
    useCaseOut.last.fold(
      matchOnError: {
        On<CollectionUseCaseError>(_matchOnCollectionUseCaseError)
      },
      defaultOnError: _defaultOnError,
      onValue: (collection) => _collection = collection,
    );
    return _collection;
  }

  @override
  Future<CreateCollectionState?> computeState() async {
    if (_useCaseError != null) {
      return state.copyWith(errorMessage: _useCaseError);
    }
    return CreateCollectionState(collectionName: _collectionName);
  }
}
