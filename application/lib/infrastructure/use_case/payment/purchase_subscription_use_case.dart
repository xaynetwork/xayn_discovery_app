import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/aip_error_to_payment_flow_error_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class PurchaseSubscriptionUseCase
    extends UseCase<PurchasableProductId, PurchasableProductStatus> {
  final PaymentService _paymentService;
  final PurchasesErrorCodeToPaymentFlowErrorMapper _errorMapper;

  PurchaseSubscriptionUseCase(
    this._paymentService,
    this._errorMapper,
  );

  @override
  Stream<PurchasableProductStatus> transaction(
    PurchasableProductId param,
  ) async* {
    yield PurchasableProductStatus.pending;
    try {
      final info = await _paymentService.purchaseProduct(param);
      yield info.activeSubscriptions.contains(param)
          ? PurchasableProductStatus.purchased
          : throw PaymentFlowError.paymentFailed;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        yield PurchasableProductStatus.canceled;
        return;
      }
      throw _errorMapper.map(errorCode);
    }
  }
}
