import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages the state for the material app.
///
/// It it used to initialise the App with initial data like AppTheme.
/// And also listen for changes to AppTheme.
@injectable
class AppManager extends Cubit<AppState> with UseCaseBlocHelper<AppState> {
  AppManager(
    this._getAppThemeUseCase,
    this._listenAppThemeUseCase,
  ) : super(AppState.empty()) {
    _init();
  }

  final GetAppThemeUseCase _getAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  late final UseCaseValueStream<AppTheme> _appThemeHandler;

  late AppTheme _appTheme;
  bool _initDone = false;

  void _init() async {
    scheduleComputeState(() async {
      _appTheme = await _getAppThemeUseCase.singleOutput(none);
      _appThemeHandler = consume(_listenAppThemeUseCase, initialData: none);
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
