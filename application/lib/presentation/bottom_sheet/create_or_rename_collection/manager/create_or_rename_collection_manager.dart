import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/collection_card/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import 'create_or_rename_collection_state.dart';

@injectable
class CreateOrRenameCollectionManager
    extends Cubit<CreateOrRenameCollectionState>
    with UseCaseBlocHelper<CreateOrRenameCollectionState> {
  final CreateCollectionUseCase _createCollectionUseCase;
  final RenameCollectionUseCase _renameCollectionUseCase;
  final CollectionErrorsEnumMapper _collectionErrorsEnumMapper;

  late final UseCaseSink<String, Collection> _createCollectionHandler =
      pipe(_createCollectionUseCase);
  late final UseCaseSink<RenameCollectionUseCaseParam, Collection>
      _renameCollectionHandler = pipe(_renameCollectionUseCase);

  String _collectionName = '';
  bool _checkForError = false;

  CreateOrRenameCollectionManager(
    this._createCollectionUseCase,
    this._collectionErrorsEnumMapper,
    this._renameCollectionUseCase,
  ) : super(CreateOrRenameCollectionState.initial());

  void updateCollectionName(String name) =>
      scheduleComputeState(() => _collectionName = name);

  void createCollection() {
    _checkForError = true;
    _createCollectionHandler(state.collectionName);
  }

  void renameCollection(UniqueId collectionId) async {
    _checkForError = true;
    final param = RenameCollectionUseCaseParam(
      collectionId: collectionId,
      newName: state.collectionName,
    );
    _renameCollectionHandler(
      param,
    );
  }

  @override
  Future<CreateOrRenameCollectionState?> computeState() async =>
      fold2(_createCollectionHandler, _renameCollectionHandler)
          .foldAll((newCollection, renamedCollection, errorReport) {
        if (errorReport.isNotEmpty && _checkForError) {
          _checkForError = false;
          final report = errorReport.of(_createCollectionHandler) ??
              errorReport.of(_renameCollectionHandler);
          final error = report!.error as CollectionUseCaseError;
          logger.e(error);
          final errorMessage =
              _collectionErrorsEnumMapper.mapEnumToString(error);
          return state.copyWith(error: ErrorObject(error, errorMessage));
        }

        _checkForError = false;

        if (newCollection != null) {
          return CreateOrRenameCollectionState.populateCollection(
            newCollection,
          );
        }

        if (renamedCollection != null) {
          return CreateOrRenameCollectionState.populateCollection(
            renamedCollection,
          );
        }

        return CreateOrRenameCollectionState.populateCollectionName(
          _collectionName,
        );
      });
}
