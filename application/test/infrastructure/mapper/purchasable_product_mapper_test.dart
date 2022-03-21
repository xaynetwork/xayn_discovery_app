import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/models/product_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/purchasable_product_mapper.dart';

void main() {
  final mapper = PurchasableProductMapper();

  const details = <Product>[
    Product(
      'id_0',
      'description_0',
      'title_0',
      0.0,
      'price_0',
      'code_0',
    ),
    Product(
      'id_1',
      'description_1',
      'title_1',
      1.0,
      'price_1',
      'code_1',
    ),
    Product(
      'id_2',
      'description_2',
      'title_2',
      2.0,
      'price_2',
      'code_2',
    ),
    Product(
      'id_3',
      'description_3',
      'title_3',
      3.0,
      'price_3',
      'code_3',
    ),
  ];

  const expectedProducts = <PurchasableProduct>[
    PurchasableProduct(
      id: 'id_0',
      title: 'title_0',
      description: 'description_0',
      price: 'price_0',
      currency: 'code_0',
      status: PurchasableProductStatus.purchasable,
    ),
    PurchasableProduct(
      id: 'id_1',
      title: 'title_1',
      description: 'description_1',
      price: 'price_1',
      currency: 'code_1',
      status: PurchasableProductStatus.purchasable,
    ),
    PurchasableProduct(
      id: 'id_2',
      title: 'title_2',
      description: 'description_2',
      price: 'price_2',
      currency: 'code_2',
      status: PurchasableProductStatus.purchasable,
    ),
    PurchasableProduct(
      id: 'id_3',
      title: 'title_3',
      description: 'description_3',
      price: 'price_3',
      currency: 'code_3',
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
