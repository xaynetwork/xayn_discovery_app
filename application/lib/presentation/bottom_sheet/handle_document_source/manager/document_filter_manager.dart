import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/crud_document_filter_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/handle_document_source/manager/document_filter_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class DocumentFilterManager extends Cubit<DocumentFilterState>
    with UseCaseBlocHelper<DocumentFilterState> {
  final CrudDocumentFilterUseCase _documentFilterUseCase;
  final Document _document;

  DocumentFilterManager(
    this._documentFilterUseCase,

    /// must be passed with di.get(param1 : document)
    @factoryParam this._document,
  ) : super(const DocumentFilterState(filters: {})) {
    _handler(const DbCrudIn.getAll());
  }

  late final _getAllAfterChanged = consume(_documentFilterUseCase,
          initialData: const DbCrudIn.watchAll())
      .transform(
          (out) => _documentFilterUseCase.transaction(const DbCrudIn.getAll()));

  late final _handler = pipe(_documentFilterUseCase);
  late final _pendingChanges = <DocumentFilter, bool>{
    DocumentFilter.fromSource(_document.resource.sourceDomain): false,
  };

  @override
  Future<DocumentFilterState?> computeState() async => fold2(
        _getAllAfterChanged,
        _handler,
      ).foldAll((
        getAll,
        handler,
        errorReport,
      ) {
        final list = (getAll ?? handler)?.mapOrNull(list: (v) => v.value) ?? [];

        final filters = {
          ..._pendingChanges,
          for (var key in list) key!: true,
        };

        return DocumentFilterState(filters: filters);
      });

  void onFilterTogglePressed(DocumentFilter filter) {
    scheduleComputeState(() {
      _pendingChanges[filter] = !(_pendingChanges[filter] ?? false);
    });
  }

  void onApplyChangesPressed() {
    _documentFilterUseCase.applyChanges(_pendingChanges);
  }
}
