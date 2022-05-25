import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/apply_document_filter_in.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/apply_document_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/crud_document_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/user_interactions_events.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/manager/document_filter_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class DocumentFilterManager extends Cubit<DocumentFilterState>
    with UseCaseBlocHelper<DocumentFilterState> {
  final CrudDocumentFilterUseCase _documentFilterUseCase;
  final ApplyDocumentFilterUseCase _applyDocumentFilterUseCase;
  final Document _document;
  final SaveUserInteractionUseCase _saveUserInteractionUseCase;

  DocumentFilterManager(
    this._documentFilterUseCase,
    this._applyDocumentFilterUseCase,
    this._saveUserInteractionUseCase,

    /// must be passed with di.get(param1 : document)
    @factoryParam this._document,
  ) : super(const DocumentFilterState(filters: {}, hasPendingChanges: false)) {
    _handler(const DbCrudIn.getAll());
  }

  late final _getAllAfterChanged = consume(_documentFilterUseCase,
      initialData: const DbCrudIn.getAllContinuously());

  late final _handler = pipe(_documentFilterUseCase);
  late final _pendingChanges = <DocumentFilter, bool>{};

  @override
  Future<DocumentFilterState?> computeState() async => fold2(
        _getAllAfterChanged,
        _handler,
      ).foldAll((
        getAll,
        handler,
        errorReport,
      ) {
        final filter =
            DocumentFilter.fromSource(_document.resource.sourceDomain.value);
        final list = (getAll ?? handler)?.mapOrNull(list: (v) => v.value) ?? [];
        list.removeWhere(
          (element) =>
              element!.fold((host) => element != filter, (topic) => false),
        );

        final filters = {
          for (var key in list) key!: true,
          ..._pendingChanges,
        };
        filters.putIfAbsent(filter, () => false);

        return DocumentFilterState(
            filters: filters, hasPendingChanges: _pendingChanges.isNotEmpty);
      });

  void onFilterTogglePressed(DocumentFilter filter) {
    scheduleComputeState(() {
      final value = state.filters[filter] ?? false;
      _pendingChanges[filter] = !value;
    });
  }

  // Future is only passed for tests
  Future onApplyChangesPressed() {
    _saveUserInteractionUseCase
        .singleOutput(UserInteractionsEvents.excludedSource);
    return _applyDocumentFilterUseCase.singleOutput(
      ApplyDocumentFilterIn.applyChangesToDbAndEngine(
        changes: _pendingChanges,
      ),
    );
  }
}
