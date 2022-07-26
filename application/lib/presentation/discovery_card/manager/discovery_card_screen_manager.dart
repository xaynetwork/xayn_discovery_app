import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_settings_menu_displayed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/get_document_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/check_valid_document_mixin.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

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
    @factoryParam UniqueId? documentId,
    @factoryParam Document? document,
    this._getDocumentUseCase,
    this._navActions,
    this._sendAnalyticsUseCase,
  )   : assert(
          documentId != null || document != null,
          'Please provide either a document or a document id',
        ),
        super(DiscoveryCardScreenState.initial()) {
    _init(documentId, document);
  }

  void _init(UniqueId? documentId, Document? document) {
    if (document != null) {
      scheduleComputeState(
        () => _document = document,
      );
    } else if (documentId != null) {
      _getDocumentHandler(
        documentId,
      );
    }
  }

  final SendAnalyticsUseCase _sendAnalyticsUseCase;
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
            currentView: CurrentView.bookmark,
          );
          return DiscoveryCardScreenState.populated(document: _document);
        }
      });

  @override
  void onBackPressed() => _navActions.onBackPressed();

  void onReaderModeMenuDisplayed({required bool isVisible}) =>
      _sendAnalyticsUseCase(
        ReaderModeSettingsMenuDisplayedEvent(
          isVisible: isVisible,
        ),
      );
}
