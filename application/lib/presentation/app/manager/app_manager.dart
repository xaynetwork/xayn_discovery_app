import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_collection_and_bookmark_changes_identity_param_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_initial_identity_params_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_lifecycle/app_lifecycle_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/save_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_default_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// Manages the state for the material app.
///
/// It it used to initialise the App with initial data like AppTheme.
/// And also listen for changes to AppTheme.
@lazySingleton
class AppManager extends Cubit<AppState> with UseCaseBlocHelper<AppState> {
  AppManager(
    this._listenAppThemeUseCase,
    this._incrementAppSessionUseCase,
    this._createOrGetDefaultCollectionUseCase,
    this._renameDefaultCollectionUseCase,
    this._setInitialIdentityParamsUseCase,
    this._setCollectionAndBookmarksChangesIdentityParam,
    this._appLifecycleUseCase,
    AppSettingsRepository appSettingsRepository,
  ) : super(AppState(appTheme: appSettingsRepository.settings.appTheme)) {
    _init();
  }

  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final IncrementAppSessionUseCase _incrementAppSessionUseCase;
  final SetInitialIdentityParamsUseCase _setInitialIdentityParamsUseCase;
  final CreateOrGetDefaultCollectionUseCase
      _createOrGetDefaultCollectionUseCase;
  final RenameDefaultCollectionUseCase _renameDefaultCollectionUseCase;
  final SetCollectionAndBookmarksChangesIdentityParam
      _setCollectionAndBookmarksChangesIdentityParam;
  late final UseCaseValueStream<AppTheme> _appThemeHandler;
  final AppLifecycleUseCase _appLifecycleUseCase;

  bool _initDone = false;

  void _init() async {
    scheduleComputeState(() async {
      await _incrementAppSessionUseCase.call(none);
      await _createOrGetDefaultCollectionUseCase
          .call(R.strings.defaultCollectionNameReadLater);
      _appThemeHandler = consume(_listenAppThemeUseCase, initialData: none);
      _setAnalyticsEvents();
      _initDone = true;
    });
    _addListener();
  }

  Future<void> maybeUpdateDefaultCollectionName() =>
      _renameDefaultCollectionUseCase
          .call(R.strings.defaultCollectionNameReadLater);

  @override
  Future<AppState?> computeState() async {
    if (!_initDone) return null;
    return fold(_appThemeHandler).foldAll(
        (appTheme, _) => AppState(appTheme: appTheme ?? state.appTheme));
  }

  void _setAnalyticsEvents() {
    _setInitialIdentityParamsUseCase.call(none);
  }

  void _addListener() {
    _setCollectionAndBookmarksChangesIdentityParam.call(none);
  }

  void onPause() => _appLifecycleUseCase.updateOnPause(true);

  void onResume() => _appLifecycleUseCase.updateOnPause(false);
}
