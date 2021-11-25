import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/use_case_extension.dart';

@injectable
class SaveAppThemeUseCase extends UseCase<AppTheme, None> {
  final FakeAppThemeStorage _storage;

  SaveAppThemeUseCase(this._storage);

  @override
  Stream<None> transaction(AppTheme param) async* {
    await Future.delayed(const Duration(milliseconds: 42));
    _storage.value = param;
    yield none;
  }
}
