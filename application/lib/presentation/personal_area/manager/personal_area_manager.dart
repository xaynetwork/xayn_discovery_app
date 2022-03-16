import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';

abstract class PersonalAreaNavActions {
  void onHomeNavPressed();

  void onActiveSearchNavPressed();

  void onCollectionsNavPressed();

  void onHomeFeedSettingsNavPressed();

  void onSettingsNavPressed();
}

@lazySingleton
class PersonalAreaManager extends Cubit<PersonalAreaState>
    with
        UseCaseBlocHelper<PersonalAreaState>,
        OpenExternalUrlMixin<PersonalAreaState>
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
}
