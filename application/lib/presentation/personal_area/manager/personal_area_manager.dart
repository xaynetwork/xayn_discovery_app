import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';

abstract class PersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onCollectionsNavPressed();

  void onHomeFeedSettingsNavPressed();

  void onSettingsNavPressed();

  void onContactNavPressed();
}

@lazySingleton
class PersonalAreaManager extends Cubit<PersonalAreaState>
    implements PersonalAreaNavActions {
  final PersonalAreaNavActions _navActions;

  PersonalAreaManager(
    this._navActions,
  ) : super(PersonalAreaState.initial());

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

  @override
  void onContactNavPressed() => _navActions.onContactNavPressed();
}
