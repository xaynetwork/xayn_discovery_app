import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';

/// This class is just a proxy for [InAppPurchase].
/// I created it, in order to be able to mock the behaviour in the useCases.
/// Unfortunately right now there is an issue with Mockito package we are using:
/// it is not supporting code generation for the methods that return generics.
/// In current case it is [InAppPurchase.getPlatformAddition]
/// which we are not using so far.
/// The issue described here: https://github.com/dart-lang/mockito/issues/338
@lazySingleton
class PaymentService {
  /// This class is the only one place where we use [InAppPurchase]
  late final _appPurchase = InAppPurchase.instance;

  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) =>
      _appPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: autoConsume,
      );

  Future<bool> buyNonConsumable({
    required PurchaseParam purchaseParam,
  }) =>
      _appPurchase.buyNonConsumable(purchaseParam: purchaseParam);

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
