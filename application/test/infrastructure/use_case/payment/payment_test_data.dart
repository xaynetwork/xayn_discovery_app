import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';

const subscriptionId = PurchasableIds.subscription;

const product = Product(
  subscriptionId,
  'description',
  'title',
  0,
  'price',
  'currencyCode',
);
final productDetails = ProductDetails(
  id: subscriptionId,
  title: 'title',
  description: 'description',
  price: 'price',
  rawPrice: 0,
  currencyCode: 'currencyCode',
);

final iapError = IAPError(source: 'source', code: 'code', message: 'message');

final restoredPurchaseDetails = createPurchase(PurchaseStatus.restored);
final purchasedPurchaseDetails = createPurchase(PurchaseStatus.purchased);

PurchaseDetails createPurchase(
  PurchaseStatus status, {
  String id = subscriptionId,
}) {
  final details = PurchaseDetails(
    productID: id,
    status: status,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'localVerificationData',
      serverVerificationData: 'serverVerificationData',
      source: 'source',
    ),
    transactionDate: 'transactionDate',
  );
  if (status == PurchaseStatus.error) {
    details.error = iapError;
  }
  return details;
}

PurchaseDetails mapStatusToPurchaseDetails(PurchaseStatus status) {
  switch (status) {
    case PurchaseStatus.purchased:
      return purchasedPurchaseDetails;
    case PurchaseStatus.restored:
      return restoredPurchaseDetails;
    default:
      return createPurchase(status);
  }
}

const purchasableProduct = PurchasableProduct(
  id: subscriptionId,
  title: 't',
  description: 'd',
  price: 'p',
  status: PurchasableProductStatus.purchasable,
);
