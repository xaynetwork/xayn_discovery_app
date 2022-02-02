import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class CheckSubscriptionActiveUseCase
    extends UseCase<PurchasableProductId, bool> {
  final PaymentService _paymentService;

  CheckSubscriptionActiveUseCase(this._paymentService);

  /// yield [true] if subscription for [PurchasableProduct] with id[param]
  /// is active (restored)
  /// otherwise yield [false]
  @override
  Stream<bool> transaction(PurchasableProductId param) async* {
    final isAvailable = await _paymentService.isAvailable();
    if (!isAvailable) {
      throw PaymentFlowError.storeNotAvailable;
    }

    bool checkIfAvailable(PurchaseDetails purchase) =>
        purchase.status == PurchaseStatus.restored &&
        purchase.productID == param;

    _paymentService.restorePurchases();
    final purchases = await _paymentService.purchaseStream.first;
    yield purchases.where(checkIfAvailable).isNotEmpty;
  }
}
