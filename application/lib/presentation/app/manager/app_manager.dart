import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages the state for the material app.
///
/// It it used to initialise the App with initial data like AppTheme.
@injectable
class AppManager extends Cubit<AppState> with UseCaseBlocHelper<AppState> {
  AppManager(
    this._getAppThemeUseCase,
  ) : super(AppState.empty()) {
    _init();
  }

  final GetAppThemeUseCase _getAppThemeUseCase;
  late AppTheme _appTheme;
  bool _initDone = false;

  void _init() async {
    scheduleComputeState(() async {
      _appTheme = await _getAppThemeUseCase.singleOutput(none);
      _initDone = true;
    });
  }

  @override
  Future<AppState?> computeState() async {
    if (!_initDone) return null;
    return AppState(appTheme: _appTheme);
  }
}
