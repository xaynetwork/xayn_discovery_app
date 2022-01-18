import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/save_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_default_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// Manages the state for the material app.
///
/// It it used to initialise the App with initial data like AppTheme.
/// And also listen for changes to AppTheme.
@lazySingleton
class AppManager extends Cubit<AppState> with UseCaseBlocHelper<AppState> {
  AppManager(
    this._getAppThemeUseCase,
    this._listenAppThemeUseCase,
    this._incrementAppSessionUseCase,
    this._createOrGetDefaultCollectionUseCase,
    this._createDefaultCollectionUseCase,
  ) : super(AppState.empty()) {
    _init();
  }

  final GetAppThemeUseCase _getAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final IncrementAppSessionUseCase _incrementAppSessionUseCase;
  final CreateOrGetDefaultCollectionUseCase
      _createOrGetDefaultCollectionUseCase;
  final CreateDefaultCollectionUseCase _createDefaultCollectionUseCase;
  late final UseCaseValueStream<AppTheme> _appThemeHandler;

  late AppTheme _appTheme;
  bool _initDone = false;

  void _init() async {
    scheduleComputeState(() async {
      await _incrementAppSessionUseCase.call(none);
      await _createOrGetDefaultCollectionUseCase
          .call(R.strings.defaultCollectionNameReadLater);
      _appTheme = await _getAppThemeUseCase.singleOutput(none);
      _appThemeHandler = consume(_listenAppThemeUseCase, initialData: none);
      _createDefaultCollectionUseCase.singleOutput('Read Later');
      _initDone = true;
    });
  }

  @override
  Future<AppState?> computeState() async {
    if (!_initDone) return null;
    return fold(_appThemeHandler)
        .foldAll((appTheme, _) => AppState(appTheme: appTheme ?? _appTheme));
  }
}
