import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bottom_sheet_dismissed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';

import 'onboarding_state.dart';

@injectable
class OnboardingManager extends Cubit<OnboardingState>
    with UseCaseBlocHelper<OnboardingState> {
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

  OnboardingManager(
    this._sendAnalyticsUseCase, {
    @factoryParam OnboardingType? onboardingType,
  }) : super(
          OnboardingState(onboardingType: onboardingType),
        );

  void onCancelPressed() async {
    if (state.onboardingType == null) return;

    _sendAnalyticsUseCase(
      BottomSheetDismissedEvent(
        bottomSheetView: state.onboardingType!.toBottomSheetView,
      ),
    );
  }
}
