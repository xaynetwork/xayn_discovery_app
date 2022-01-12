import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

abstract class PersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onCollectionsNavPressed();

  void onHomeFeedSettingsNavPressed();

  void onSettingsNavPressed();
}

@lazySingleton
class PersonalAreaManager extends Cubit<None>
    implements PersonalAreaNavActions {
  final PersonalAreaNavActions _navActions;

  PersonalAreaManager(
    this._navActions,
  ) : super(none);

  @override
  void onHomeNavPressed() => _navActions.onHomeNavPressed();

  @override
  void onActiveSearchNavPressed() => _navActions.onActiveSearchNavPressed();

  @override
  void onCollectionsNavPressed() => _navActions.onCollectionsNavPressed();

  @override
  void onHomeFeedSettingsNavPressed() =>
      _navActions.onHomeFeedSettingsNavPressed();

  @override
  void onSettingsNavPressed() => _navActions.onSettingsNavPressed();
}
