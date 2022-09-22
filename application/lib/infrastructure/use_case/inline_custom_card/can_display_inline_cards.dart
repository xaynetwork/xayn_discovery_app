import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/can_display_country_selection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/can_display_push_notifications_card_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/can_display_source_selection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/can_display_survey_banner_use_case.dart';

@injectable
class CanDisplayInLineCardsUseCase extends UseCase<None, bool> {
  final CanDisplayCountrySelectionUseCase _canDisplayCountrySelectionUseCase;
  final CanDisplaySourceSelectionUseCase _canDisplaySourceSelectionUseCase;
  final CanDisplaySurveyBannerUseCase _canDisplaySurveyBannerUseCase;
  final CanDisplayPushNotificationsCardUseCase
      _canDisplayPushNotificationsCardUseCase;

  CanDisplayInLineCardsUseCase(
    this._canDisplayCountrySelectionUseCase,
    this._canDisplaySourceSelectionUseCase,
    this._canDisplaySurveyBannerUseCase,
    this._canDisplayPushNotificationsCardUseCase,
  );

  @override
  Stream<bool> transaction(None param) async* {
    final canDisplayCountrySelection =
        await _canDisplayCountrySelectionUseCase.singleOutput(none);

    final canDisplaySourceSelection =
        await _canDisplaySourceSelectionUseCase.singleOutput(none);

    final canDisplaySurveyBanner =
        await _canDisplaySurveyBannerUseCase.singleOutput(none);

    final canDisplayPushNotifications =
        await _canDisplayPushNotificationsCardUseCase.singleOutput(none);

    yield canDisplayCountrySelection ||
        canDisplaySourceSelection ||
        canDisplaySurveyBanner ||
        canDisplayPushNotifications;
  }
}
