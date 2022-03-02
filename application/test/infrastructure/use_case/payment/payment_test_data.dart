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

PurchaserInfo createPurchaserInfo({bool withActiveSubscription = true}) =>
    PurchaserInfo(
      const EntitlementInfos({}, {}),
      {},
      withActiveSubscription ? [subscriptionId] : [],
      [],
      [],
      '',
      '',
      {},
      '',
    );

const purchasableProduct = PurchasableProduct(
  id: subscriptionId,
  title: 't',
  description: 'd',
  price: 'p',
  status: PurchasableProductStatus.purchasable,
);
