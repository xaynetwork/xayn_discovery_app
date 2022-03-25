import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/presentation/constants/entitlement_ids.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';

const subscriptionId = PurchasableIds.subscription;
const entitlementId = EntitlementIds.unlimited;

const product = Product(
  subscriptionId,
  'description',
  'title',
  0,
  'price',
  'currencyCode',
);

PurchaserInfo createPurchaserInfo({bool withActiveSubscription = true}) {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final isActive = withActiveSubscription;
  final willRenew = withActiveSubscription;
  final entitlementInfo = EntitlementInfo(
    entitlementId,
    isActive,
    willRenew,
    '',
    '',
    subscriptionId,
    true,
    expirationDate: withActiveSubscription ? tomorrow.toIso8601String() : null,
  );
  final entitlements = EntitlementInfos(
    {entitlementId: entitlementInfo},
    {entitlementId: entitlementInfo},
  );
  return PurchaserInfo(
    withActiveSubscription ? entitlements : const EntitlementInfos({}, {}),
    {},
    withActiveSubscription ? [entitlementId] : [],
    [],
    [],
    '',
    '',
    {},
    '',
    latestExpirationDate:
        withActiveSubscription ? tomorrow.toIso8601String() : null,
  );
}

const purchasableProduct = PurchasableProduct(
  id: subscriptionId,
  title: 't',
  description: 'd',
  price: 'p',
  currency: 'usd',
  status: PurchasableProductStatus.purchasable,
);
