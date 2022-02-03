import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/get_document_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

abstract class DiscoveryCardScreenManagerNavActions {
  void onBackPressed();
}

@injectable
class DiscoveryCardScreenManager extends Cubit<DiscoveryCardScreenState>
    with UseCaseBlocHelper<DiscoveryCardScreenState>
    implements DiscoveryCardScreenManagerNavActions {
  DiscoveryCardScreenManager(
    @factoryParam UniqueId? documentId,
    this._getDocumentUseCase,
    this._navActions,
  ) : super(DiscoveryCardScreenState.initial()) {
    _getDocumentHandler(documentId!);
  }

  final GetDocumentUseCase _getDocumentUseCase;
  final DiscoveryCardScreenManagerNavActions _navActions;
  late final _getDocumentHandler = pipe(_getDocumentUseCase);

  @override
  Future<DiscoveryCardScreenState?> computeState() async => fold(
        _getDocumentHandler,
      ).foldAll((
        getDocument,
        errorReport,
      ) {
        if (getDocument != null) {
          return DiscoveryCardScreenState.populated(document: getDocument);
        }

        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_getDocumentHandler);
          logger.e(
              'Could not retrieve document', error?.error, error?.stackTrace);
          onBackPressed();
        }
      });

  @override
  void onBackPressed() {
    _navActions.onBackPressed();
  }
}
