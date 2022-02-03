import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

import 'create_collection_state.dart';

@injectable
class CreateCollectionManager extends Cubit<CreateCollectionState>
    with UseCaseBlocHelper<CreateCollectionState> {
  final CreateCollectionUseCase _createCollectionUseCase;
  final CollectionErrorsEnumMapper _collectionErrorsEnumMapper;
  late UseCaseSink<String, Collection> _createCollectionHandler;

  String _collectionName = '';
  bool _checkForError = false;

  CreateCollectionManager(
    this._createCollectionUseCase,
    this._collectionErrorsEnumMapper,
  ) : super(CreateCollectionState.initial()) {
    _init();
  }

  void _init() {
    _createCollectionHandler = pipe(_createCollectionUseCase);
  }

  void updateCollectionName(String name) =>
      scheduleComputeState(() => _collectionName = name);

  void createCollection() {
    _checkForError = true;
    _createCollectionHandler(state.collectionName);
  }

  @override
  Future<CreateCollectionState?> computeState() async =>
      fold(_createCollectionHandler).foldAll((newCollection, errorReport) {
        if (errorReport.isNotEmpty && _checkForError) {
          _checkForError = false;
          final error = errorReport.of(_createCollectionHandler)!.error
              as CollectionUseCaseError;
          logger.e(error);
          final errorMessage =
              _collectionErrorsEnumMapper.mapEnumToString(error);
          return state.copyWith(errorMessage: errorMessage);
        }

        _checkForError = false;

        if (newCollection != null) {
          return CreateCollectionState.populateCollection(newCollection);
        }

        return CreateCollectionState.populateCollectionName(_collectionName);
      });
}
