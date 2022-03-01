import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class GetSubscriptionStatusUseCase
    extends UseCase<PurchasableProductId, SubscriptionStatus> {
  final PaymentService _paymentService;

  GetSubscriptionStatusUseCase(this._paymentService);

  /// yield [true] if subscription for [PurchasableProduct] with id[param]
  /// is active
  /// otherwise yield [false]
  @override
  Stream<SubscriptionStatus> transaction(PurchasableProductId param) async* {
    final purchaserInfo = await _paymentService.getPurchaserInfo();
    final entitlement = purchaserInfo.entitlements.active[param];
    final willRenew = entitlement?.willRenew ?? false;
    final expirationDateString = entitlement?.expirationDate;
    final expirationDate = expirationDateString != null
        ? DateTime.parse(expirationDateString)
        : null;
    yield SubscriptionStatus(
      willRenew: willRenew,
      expirationDate: expirationDate,
    );
  }
}
