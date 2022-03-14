import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/urls.dart';
import 'package:xayn_discovery_app/presentation/contact/manager/contact_state.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';

abstract class ContactNavActions {
  void onBackNavPressed();
}

@lazySingleton
class ContactScreenManager extends Cubit<ContactScreenState>
    with
        UseCaseBlocHelper<ContactScreenState>,
        OpenExternalUrlMixin<ContactScreenState>
    implements ContactNavActions {
  final FeatureManager _featureManager;
  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetAppThemeUseCase _getAppThemeUseCase;
  final SaveAppThemeUseCase _saveAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final BugReportingService _bugReportingService;
  final ExtractLogUseCase _extractLogUseCase;
  final ContactNavActions _contactNavActions;
  final ShareUriUseCase _shareUriUseCase;

  ContactScreenManager(
    this._getAppVersionUseCase,
    this._getAppThemeUseCase,
    this._saveAppThemeUseCase,
    this._listenAppThemeUseCase,
    this._bugReportingService,
    this._extractLogUseCase,
    this._contactNavActions,
    this._shareUriUseCase,
    this._featureManager,
  ) : super(const ContactScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late final AppVersion _appVersion;
  late final UseCaseValueStream<AppTheme> _appThemeHandler;

  void _init() async {
    scheduleComputeState(() async {
      // read values
      _appVersion = await _getAppVersionUseCase.singleOutput(none);
      _theme = await _getAppThemeUseCase.singleOutput(none);

      // attach listeners
      _appThemeHandler = consume(_listenAppThemeUseCase, initialData: none);

      _initDone = true;
    });
  }

  void saveTheme(AppTheme theme) => _saveAppThemeUseCase.call(theme);

  Future<void> extractLogs() => _extractLogUseCase.call(none);

  void reportBug() => _bugReportingService.showDialog(
        brightness: R.brightness,
        primaryColor: R.colors.primaryAction,
      );

  void shareApp() => _shareUriUseCase.call(Uri.parse(Urls.download));

  @override
  Future<ContactScreenState?> computeState() async {
    if (!_initDone) return null;
    ContactScreenState buildReady() => ContactScreenState.ready(
          theme: _theme,
          appVersion: _appVersion,
          isPaymentEnabled: _featureManager.isPaymentEnabled,
        );
    return fold(_appThemeHandler).foldAll((appTheme, _) async {
      if (appTheme != null) {
        _theme = appTheme;
      }

      return buildReady();
    });
  }

  @override
  void onBackNavPressed() => _contactNavActions.onBackNavPressed();
}
