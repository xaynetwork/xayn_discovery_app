import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_settings_menu_displayed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/get_document_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_screen_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/error/mixin/error_handling_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

abstract class DiscoveryCardScreenManagerNavActions {
  void onBackPressed();
}

@injectable
class DiscoveryCardScreenManager extends Cubit<DiscoveryCardScreenState>
    with
        UseCaseBlocHelper<DiscoveryCardScreenState>,
        OverlayManagerMixin<DiscoveryCardScreenState>,
        ErrorHandlingManagerMixin<DiscoveryCardScreenState>
    implements DiscoveryCardScreenManagerNavActions {
  DiscoveryCardScreenManager(
    @factoryParam UniqueId? documentId,
    this._getDocumentUseCase,
    this._navActions,
    this._sendAnalyticsUseCase,
  ) : super(DiscoveryCardScreenState.initial()) {
    _getDocumentHandler(documentId!);
  }

  final SendAnalyticsUseCase _sendAnalyticsUseCase;
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
          openErrorScreen();
          // return DiscoveryCardScreenState.error();
        }
      });

  @override
  void onBackPressed() {
    _navActions.onBackPressed();
  }

  void onReaderModeMenuDisplayed({required bool isVisible}) =>
      _sendAnalyticsUseCase(
        ReaderModeSettingsMenuDisplayedEvent(
          isVisible: isVisible,
        ),
      );
}
