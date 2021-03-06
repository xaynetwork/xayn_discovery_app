import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class GetSubscriptionManagementUrlUseCase
    extends UseCase<None, GetSubscriptionManagementUrlOutput> {
  final PaymentService _paymentService;

  GetSubscriptionManagementUrlUseCase(
    this._paymentService,
  );

  /// yields a subscription management url for current platform
  @override
  Stream<GetSubscriptionManagementUrlOutput> transaction(None param) async* {
    final url = await _paymentService.subscriptionManagementURL;
    yield GetSubscriptionManagementUrlOutput(url);
  }
}

class GetSubscriptionManagementUrlOutput {
  final String? url;

  GetSubscriptionManagementUrlOutput(this.url);
}
