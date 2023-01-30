import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';

import 'onboarding_state.dart';

@injectable
class OnboardingManager extends Cubit<OnboardingState>
    with UseCaseBlocHelper<OnboardingState> {
  OnboardingManager({
    @factoryParam OnboardingType? onboardingType,
  }) : super(
          OnboardingState(onboardingType: onboardingType),
        );
}
