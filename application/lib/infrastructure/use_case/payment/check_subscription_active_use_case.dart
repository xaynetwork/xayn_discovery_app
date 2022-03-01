import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class CheckSubscriptionActiveUseCase
    extends UseCase<PurchasableProductId, bool> {
  final PaymentService _paymentService;

  CheckSubscriptionActiveUseCase(this._paymentService);

  /// yield [true] if subscription for [PurchasableProduct] with id[param]
  /// is active
  /// otherwise yield [false]
  @override
  Stream<bool> transaction(PurchasableProductId param) async* {
    final purchaserInfo = await _paymentService.getPurchaserInfo();
    yield purchaserInfo.activeSubscriptions.contains(param);
  }
}
