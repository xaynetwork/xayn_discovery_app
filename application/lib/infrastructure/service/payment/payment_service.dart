import 'dart:io';

import 'package:flutter/services.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';

const _pendingTransactionForSameProduct = 'storekit_duplicate_product_object';

/// This class is just a proxy for [InAppPurchase].
/// I created it, in order to be able to mock the behaviour in the useCases.
/// Unfortunately right now there is an issue with Mockito package we are using:
/// it is not supporting code generation for the methods that return generics.
/// In current case it is [InAppPurchase.getPlatformAddition]
/// which we are not using so far.
/// The issue described here: https://github.com/dart-lang/mockito/issues/338
@lazySingleton
class PaymentService {
  final BugReportingService _bugReportingService;

  /// This class is the only one place where we use [InAppPurchase]
  late final _appPurchase = InAppPurchase.instance;

  PaymentService(this._bugReportingService);

  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) =>
      _appPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: autoConsume,
      );

  /// This method contains an extra code.
  /// It's needed due to bug, described here: https://github.com/flutter/flutter/issues/60763#issuecomment-705833964%20%20%20%20%5B1%5D:%20https://github.com/flutter/flutter/issues/60763
  /// Solution in this comment: https://github.com/flutter/flutter/issues/60763#issuecomment-705833964
  Future<bool> buyNonConsumable({
    required PurchaseParam purchaseParam,
  }) async {
    if (Platform.isIOS) {
      var transactions = await SKPaymentQueueWrapper().transactions();
      for (final skPaymentTransactionWrapper in transactions) {
        SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
      }
    }
    try {
      return await _appPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } on PlatformException catch (e, trace) {
      if (e.code != _pendingTransactionForSameProduct) {
        _bugReportingService.reportHandledCrash(e, trace);
        rethrow;
      }
      return false;
    }
  }

  Future<void> completePurchase(PurchaseDetails purchase) =>
      _appPurchase.completePurchase(purchase);

  Future<bool> isAvailable() => _appPurchase.isAvailable();

  Stream<List<PurchaseDetails>> get purchaseStream =>
      _appPurchase.purchaseStream;

  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      _appPurchase.queryProductDetails(identifiers);

  Future<void> restorePurchases({String? applicationUserName}) =>
      _appPurchase.restorePurchases(applicationUserName: applicationUserName);
}
