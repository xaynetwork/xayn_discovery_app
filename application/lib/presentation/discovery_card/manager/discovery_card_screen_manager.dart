import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/get_document_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/check_valid_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

abstract class DiscoveryCardScreenManagerNavActions {
  void onBackPressed();
}

@injectable
class DiscoveryCardScreenManager extends Cubit<DiscoveryCardScreenState>
    with
        UseCaseBlocHelper<DiscoveryCardScreenState>,
        OverlayManagerMixin<DiscoveryCardScreenState>,
        ErrorHandlingManagerMixin<DiscoveryCardScreenState>,
        CheckValidDocumentMixin<DiscoveryCardScreenState>
    implements DiscoveryCardScreenManagerNavActions {
  DiscoveryCardScreenManager(
    this._getDocumentUseCase,
    this._navActions,
  ) : super(DiscoveryCardScreenState.initial());

  void initWithDocumentId({
    required UniqueId documentId,
  }) =>
      _getDocumentHandler(documentId);

  void initWithDocument({
    required Document document,
  }) =>
      scheduleComputeState(
        () => _document = document,
      );

  final GetDocumentUseCase _getDocumentUseCase;
  final DiscoveryCardScreenManagerNavActions _navActions;
  late final _getDocumentHandler = pipe(_getDocumentUseCase);
  late Document _document;

  @override
  Future<DiscoveryCardScreenState?> computeState() async => fold(
        _getDocumentHandler,
      ).foldAll((
        getDocument,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          final error = errorReport.of(_getDocumentHandler);
          logger.e(
              'Could not retrieve document', error?.error, error?.stackTrace);
          openErrorScreen();
        } else {
          if (getDocument != null) {
            _document = getDocument;
          }

          checkIfDocumentNotProcessable(
            _document,
            isDismissible: false,
            onClosePressed: onBackPressed,
          );
          return DiscoveryCardScreenState.populated(document: _document);
        }
      });

  @override
  void onBackPressed() => _navActions.onBackPressed();
}
