import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' hide PurchaseStatus;
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchasable_product_mapper.dart';

void main() {
  final mapper = PurchasableProductMapper();

  final details = <ProductDetails>[
    ProductDetails(
      id: 'id_0',
      title: 'title_0',
      description: 'description_0',
      price: 'price_0',
      rawPrice: 0,
      currencyCode: 'code_0',
    ),
    ProductDetails(
      id: 'id_1',
      title: 'title_1',
      description: 'description_1',
      price: 'price_1',
      rawPrice: 1,
      currencyCode: 'code_1',
    ),
    ProductDetails(
      id: 'id_2',
      title: 'title_2',
      description: 'description_2',
      price: 'price_2',
      rawPrice: 2,
      currencyCode: 'code_2',
    ),
    ProductDetails(
      id: 'id_3',
      title: 'title_3',
      description: 'description_3',
      price: 'price_3',
      rawPrice: 3,
      currencyCode: 'code_3',
    ),
  ];

  const expectedProducts = <PurchasableProduct>[
    PurchasableProduct(
      id: 'id_0',
      title: 'title_0',
      description: 'description_0',
      price: 'price_0',
      status: PurchasableProductStatus.purchasable,
    ),
    PurchasableProduct(
      id: 'id_1',
      title: 'title_1',
      description: 'description_1',
      price: 'price_1',
      status: PurchasableProductStatus.purchasable,
    ),
    PurchasableProduct(
      id: 'id_2',
      title: 'title_2',
      description: 'description_2',
      price: 'price_2',
      status: PurchasableProductStatus.purchasable,
    ),
    PurchasableProduct(
      id: 'id_3',
      title: 'title_3',
      description: 'description_3',
      price: 'price_3',
      status: PurchasableProductStatus.purchasable,
    ),
  ];

  test(
    'GIVEN list of details WHEN map them to product THEN verify result is correct',
    () {
      final result = details.map(mapper.map).toList();
      expect(result, equals(expectedProducts));
    },
  );
}
