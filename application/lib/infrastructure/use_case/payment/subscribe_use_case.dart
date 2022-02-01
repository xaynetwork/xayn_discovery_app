import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';

@injectable
class SubscribeUseCase extends UseCase<None, None> {
  final PaymentService _paymentService;

  SubscribeUseCase(this._paymentService);

  @override
  Stream<None> transaction(None param) async* {
    final isAvailable = await _paymentService.isAvailable();
    if (!isAvailable) {
      throw PaymentFlowError.storeNotAvailable;
    }
    const id = PurchasableIds.subscription;
    final response = await _paymentService.queryProductDetails({id});

    if (response.notFoundIDs.contains(id)) {
      throw PaymentFlowError.productNotFound;
    }

    final details = response.productDetails.first;
    await _paymentService.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: details));

    yield none;
  }
}
