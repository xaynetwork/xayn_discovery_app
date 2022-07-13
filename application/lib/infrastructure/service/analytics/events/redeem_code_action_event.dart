import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

/// An [AnalyticsEvent] which tracks when a user redeems a code in the alternative
/// redeem code bottomsheet
/// - [action] is the name of the action performed by the user.
/// - [code] the code that was redeemed
/// - [trialDaysLeftWhenEntering] the trial time left when redeeming
class RedeemCodeActionEvent extends AnalyticsEvent {
  RedeemCodeActionEvent({
    required RedeemAction action,
    required int trialDaysLeftWhenEntering,
    String? code,
  }) : super(
          'redeemCodeAction',
          properties: {
            'action': action.name,
            if (code != null) 'code': code,
            'trialDaysLeftWhenEntering': trialDaysLeftWhenEntering,
          },
        );
}

enum RedeemAction {
  applied,
  cancel,
  error,
}
