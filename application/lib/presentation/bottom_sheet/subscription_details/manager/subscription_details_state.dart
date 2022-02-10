import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_details_state.freezed.dart';

/// Represents the state of the [SubscriptionDetailsManager].
@freezed
class SubscriptionDetailsState with _$SubscriptionDetailsState {
  const factory SubscriptionDetailsState({
    required DateTime endDate,
    String? cancelUrl,
  }) = _SubscriptionDetailsState;
}
