import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/helper/apple_verify_receipt_helper.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';

@injectable
class CheckSubscriptionActiveUseCase
    extends UseCase<PurchasableProductId, bool> {
  final PaymentService _paymentService;
  final AppleVerifyReceiptHelper _iOsSubscriptionCheckHelper;
  final bool _isIOS;

  CheckSubscriptionActiveUseCase(
    this._paymentService,
    this._iOsSubscriptionCheckHelper,
  ) : _isIOS = Platform.isIOS;

  @visibleForTesting
  CheckSubscriptionActiveUseCase.test(
    this._paymentService,
    this._iOsSubscriptionCheckHelper, {
    required bool isIOS,
  }) : _isIOS = isIOS;

  /// yield [true] if subscription for [PurchasableProduct] with id[param]
  /// is active (restored)
  /// otherwise yield [false]
  @override
  Stream<bool> transaction(PurchasableProductId param) async* {
    final isAvailable = await _paymentService.isAvailable();
    if (!isAvailable) {
      throw PaymentFlowError.storeNotAvailable;
    }

    // for android status should be [PurchaseStatus.restored]
    // but for ios it is [PurchaseStatus.purchased]
    bool checkIfAvailable(PurchaseDetails purchase) =>
        purchase.productID == param &&
        purchase.status == PurchaseStatus.restored;

    _paymentService.restorePurchases();

    // we need timeout here, cos on ios if user has 0 purchases
    // `purchaseStream.first` will never return
    final purchases = await _paymentService.purchaseStream.first
        .timeout(const Duration(milliseconds: 5000), onTimeout: () => []);
    final filtered = purchases.where(checkIfAvailable);

    if (!_isIOS) {
      yield filtered.isNotEmpty;
      return;
    }

    // All further steps are just for IOS

    if (filtered.isEmpty) {
      yield false;
      return;
    }
    // for Android this is not critical, to call completePurchase.
    // but for iOs - it is.
    // If we will NOT make this call, the number of restored purchase
    // will grow with every call of `restorePurchases` method.
    for (final purchase in filtered) {
      if (purchase.pendingCompletePurchase) {
        _paymentService.completePurchase(purchase);
      }
    }

    final verificationData =
        filtered.first.verificationData.serverVerificationData;

    final subscriptionExpireDate =
        await _iOsSubscriptionCheckHelper.getSubscriptionExpireDate(
      serverVerificationData: verificationData,
      credentials: Env.appleVerifyReceiptCredentials,
    );
    if (subscriptionExpireDate == null) {
      yield false;
      return;
    }
    final isBeforeToday = DateTime.now().isBefore(subscriptionExpireDate);
    yield isBeforeToday;
  }
}
