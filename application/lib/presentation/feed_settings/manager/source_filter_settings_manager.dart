import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/apply_document_filter_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document_filter/crud_document_filter_use_case.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/source_filter_settings_state.dart';

/// This class stays in memory until we restart the App, thus we can provide a history of
/// recently deleted Filters
@singleton
class FilterDeleteHistory {
  final Set<DocumentFilter> _removedFilters = {};

  Set<DocumentFilter> get removedFilters => _removedFilters.toSet();

  void add(DocumentFilter filter) => _removedFilters.add(filter);

  void remove(DocumentFilter filter) => _removedFilters.remove(filter);

  bool contains(DocumentFilter filter) => _removedFilters.contains(filter);
}

@injectable
class SourceFilterSettingsManager extends Cubit<SourceFilterSettingsState>
    with UseCaseBlocHelper {
  final CrudDocumentFilterUseCase _documentFilterUseCase;
  final FilterDeleteHistory _filterDeleteHistory;
  final ApplyDocumentFilterUseCase _applyDocumentFilterUseCase;

  SourceFilterSettingsManager(
    this._documentFilterUseCase,
    this._filterDeleteHistory,
    this._applyDocumentFilterUseCase,
  ) : super(const SourceFilterSettingsState());

  late final _getAllAfterChanged = consume(_documentFilterUseCase,
      initialData: const DbCrudIn.getAllContinuously());

  void onSourceToggled(DocumentFilter filter) {
    if (_filterDeleteHistory.contains(filter)) {
      _filterDeleteHistory.remove(filter);
      _documentFilterUseCase.singleOutput(DbCrudIn.store(filter));
    } else {
      _filterDeleteHistory.add(filter);
      _documentFilterUseCase.singleOutput(DbCrudIn.remove(filter.id));
    }
  }

  @override
  Future<SourceFilterSettingsState> computeState() async =>
      fold(_getAllAfterChanged).foldAll((getAll, errorReport) {
        final list = (getAll)?.mapOrNull(list: (l) => l.value);
        if (list != null) {
          var allFiltersSet = list
              .cast<DocumentFilter>()
              .where((element) => element.isSource)
              .toSet();
          allFiltersSet.addAll(_filterDeleteHistory.removedFilters);

          final allFiltersList = allFiltersSet.toList();
          allFiltersList.sort(
            (a, b) => a.filterValue.compareTo(b.filterValue),
          );
          return SourceFilterSettingsState(
            filters: {
              for (var e in allFiltersList) e: !_filterDeleteHistory.contains(e)
            },
          );
        }
        return state;
      });

  void applyChanges() {
    // _applyDocumentFilterUseCase
    //     .singleOutput(const ApplyDocumentFilterIn.syncEngineWithDb());
  }
}
