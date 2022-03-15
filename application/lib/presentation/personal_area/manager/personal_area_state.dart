import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';

part 'personal_area_state.freezed.dart';

/// The state of the [PersonalAreaManager].
@freezed
class PersonalAreaState with _$PersonalAreaState {
  const PersonalAreaState._();

  const factory PersonalAreaState({
    required SubscriptionStatus subscriptionStatus,
    required bool isPaymentEnabled,
  }) = _PersonalAreaState;

  factory PersonalAreaState.initial() => PersonalAreaState(
        subscriptionStatus: SubscriptionStatus.initial(),
        isPaymentEnabled: false,
      );
}
